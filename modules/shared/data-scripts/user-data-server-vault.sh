#!/bin/bash

set -e

exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo bash /ops/shared/scripts/server.sh "${cloud_env}" "${server_count}" '${retry_join}' "${nomad_binary}" "${nomad_license_path}" "${consul_license_path}" "${datacenter}" "${recursor}" "${vault_license_path}" 

ACL_DIRECTORY="/ops/shared/config"
CONSUL_BOOTSTRAP_TOKEN="/tmp/consul_bootstrap"
NOMAD_BOOTSTRAP_TOKEN="/tmp/nomad_bootstrap"
NOMAD_USER_TOKEN="/tmp/nomad_user_token"

sed -i "s/CONSUL_TOKEN/${nomad_consul_token_secret}/g" /etc/nomad.d/nomad.hcl
sed -i "s/CONSUL_TOKEN/${nomad_consul_token_secret}/g" /etc/vault.d/vault.hcl
sed -i "s/KMS_KEY/${kms_key}/g" /etc/vault.d/vault.hcl
sed -i "s/REGION/${datacenter}/g" /etc/vault.d/vault.hcl
sed -i "s/CONSUL_TOKEN/${nomad_consul_token_secret}/g" /etc/consul.d/consul.hcl

cat << EOF > vault.hcl
ui = true
license_path="/etc.d/vault-license.hclic
"provider=aws addr_type=private_v4 tag_key=auto_join tag_value=vault-prd region=ap-southeast-1"
storage "raft" {
  path = "/opt/vault/raft"

  retry_join {
        auto_join_scheme = "http"
        auto_join = "provider=aws addr_type=private_v4 tag_key=AutoJoin tag_value=autojoin"
    }
}

cluster_addr = "http://127.0.0.1:8201"
api_addr = "http://127.0.0.1:8200"

seal "awskms" {
  region     = us-west-2
  kms_key_id = "vault-kms-unseal-nomad-mr"
}
listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "127.0.0.1:8201"
  tls_disable     = 1
}

# service_registration "consul" {
#   address      = "http://127.0.0.1:8500"
#   token = "CONSUL_TOKEN"
# }
EOF

sudo systemctl restart consul
sleep 1
sudo systemctl restart nomad
sleep 1
sudo systemctl restart vault

echo "Finished server setup"

echo "ACL bootstrap begin"

# Wait until leader has been elected and bootstrap consul ACLs
for i in {1..9}; do
    # capture stdout and stderr
    set +e
    sleep 5
    OUTPUT=$(consul acl bootstrap 2>&1)
    if [ $? -ne 0 ]; then
        echo "consul acl bootstrap: $OUTPUT"
        if [[ "$OUTPUT" = *"No cluster leader"* ]]; then
            echo "consul no cluster leader"
            continue
        else
            echo "consul already bootstrapped"
            exit 0
        fi

    fi
    set -e

    echo "$OUTPUT" | grep -i secretid | awk '{print $2}' > $CONSUL_BOOTSTRAP_TOKEN
    if [ -s $CONSUL_BOOTSTRAP_TOKEN ]; then
        echo "consul bootstrapped"
        break
    fi
done


consul acl policy create -name 'nomad-auto-join' -rules="@$ACL_DIRECTORY/consul-acl-nomad-auto-join.hcl" -token-file=$CONSUL_BOOTSTRAP_TOKEN

consul acl role create -name "nomad-auto-join" -description "Role with policies necessary for nomad servers and clients to auto-join via Consul." -policy-name "nomad-auto-join" -token-file=$CONSUL_BOOTSTRAP_TOKEN

consul acl token create -accessor=${nomad_consul_token_id} -secret=${nomad_consul_token_secret} -description "Nomad server/client auto-join token" -role-name nomad-auto-join -token-file=$CONSUL_BOOTSTRAP_TOKEN


# Wait for nomad servers to come up and bootstrap nomad ACL
for i in {1..12}; do
    # capture stdout and stderr
    set +e
    sleep 10
    OUTPUT=$(nomad acl bootstrap 2>&1)
    if [ $? -ne 0 ]; then
        echo "nomad acl bootstrap: $OUTPUT"
        if [[ "$OUTPUT" = *"No cluster leader"* ]]; then
            echo "nomad no cluster leader"
            continue
        else
            echo "nomad already bootstrapped"
            exit 0
        fi
    fi
    set -e

    echo "$OUTPUT" | grep -i secret | awk -F '=' '{print $2}' | xargs | awk 'NF' > $NOMAD_BOOTSTRAP_TOKEN
    if [ -s $NOMAD_BOOTSTRAP_TOKEN ]; then
        echo "nomad bootstrapped"
        break
    fi
done

nomad acl policy apply -token "$(cat $NOMAD_BOOTSTRAP_TOKEN)" -description "Policy to allow reading of agents and nodes and listing and submitting jobs in all namespaces." node-read-job-submit $ACL_DIRECTORY/nomad-acl-user.hcl

nomad acl token create -token "$(cat $NOMAD_BOOTSTRAP_TOKEN)" -name "read-token" -policy node-read-job-submit | grep -i secret | awk -F "=" '{print $2}' | xargs > $NOMAD_USER_TOKEN

#nomad acl token create -token "$(cat $NOMAD_BOOTSTRAP_TOKEN)" -name "read-token" -policy node-read-job-submit -global true | grep -i secret | awk -F "=" '{print $2}' | xargs > $NOMAD_GLOBAL_TOKEN

# Write user token to kv
consul kv put -token-file=$CONSUL_BOOTSTRAP_TOKEN nomad_user_token "$(cat $NOMAD_USER_TOKEN)"

echo "ACL bootstrap end"

