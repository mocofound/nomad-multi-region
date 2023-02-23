#!/bin/bash

set -e

exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo bash /ops/shared/scripts/client.sh "${cloud_env}" '${retry_join}' "${nomad_binary}" "${nomad_license_path}" "${consul_license_path}" "${datacenter}" "${recursor}"

NOMAD_HCL_PATH="/etc/nomad.d/nomad.hcl"
CONSUL_HCL_PATH="/etc/consul.d/consul.hcl"
CLOUD_ENV="${cloud_env}"

sed -i "s/CONSUL_TOKEN/${nomad_consul_token_secret}/g" $NOMAD_HCL_PATH
#TODO Create agent token
sed -i "s/CONSUL_TOKEN/${nomad_consul_token_secret}/g" $CONSUL_HCL_PATH
#sudo sed -i "s/NOMAD_LICENSE_PATH/${nomad_license_path}/g" $NOMAD_HCL_PATH
#sudo sed -i "s/CONSUL_LICENSE_PATH/${consul_license_path}/g" $CONSUL_HCL_PATH

case $CLOUD_ENV in
  aws)
    # Place the AWS instance name as metadata on the
    # client for targetting workloads
    AWS_SERVER_TAG_NAME=$(curl http://169.254.169.254/latest/meta-data/tags/instance/Name)
    sed -i "s/SERVER_NAME/$AWS_SERVER_TAG_NAME/g" $NOMAD_HCL_PATH
    ;;
  gce)
    echo "CLOUD_ENV: gce"
    ;;
  azure)
    echo "CLOUD_ENV: azure"
    ;;
  *)
    echo "CLOUD_ENV: not set"
    ;;
esac

sudo systemctl restart nomad

echo "Finished client setup"