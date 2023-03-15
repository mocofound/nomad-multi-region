#!/bin/bash

set -e

sleep 5
exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo bash /ops/shared/scripts/client.sh "${cloud_env}" '${retry_join}' "${nomad_binary}" "${nomad_license_path}" "${consul_license_path}" "${datacenter}" "${recursor}" "${nomad_consul_token_secret}"

NOMAD_HCL_PATH="/etc/nomad.d/nomad.hcl"
CONSUL_HCL_PATH="/etc/consul.d/consul.hcl"
CLOUD_ENV="${cloud_env}"


#sed -i "s/CONSUL_TOKEN//g" $NOMAD_HCL_PATH
#sed -i "s/CONSUL_TOKEN/${nomad_consul_token_secret}/g" $NOMAD_HCL_PATH
#TODO Create agent token
#sed -i "s/CONSUL_TOKEN/${nomad_consul_token_secret}/g" $CONSUL_HCL_PATH
#sed -i "s/CONSUL_TOKEN//g" $CONSUL_HCL_PATH

#sudo sed -i "s/NOMAD_LICENSE_PATH/${nomad_license_path}/g" $NOMAD_HCL_PATH
#sudo sed -i "s/CONSUL_LICENSE_PATH/${consul_license_path}/g" $CONSUL_HCL_PATH
curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v1.0.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz
echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-arptables
echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables

echo "net.bridge.bridge-nf-call-arptables = 1" | sudo tee -a /etc/sysctl.d/99-custom.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" | sudo tee -a /etc/sysctl.d/99-custom.conf
echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee -a /etc/sysctl.d/99-custom.conf

sudo apt-get install -y software-properties-common dnsmasq

sudo tee /ops/shared/config/10-consul.dnsmasq <<EOF
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
EOF

sudo tee /ops/shared/config/99-default.dnsmasq <<EOF
# 99-default.dnsmasq
server=169.254.169.253
EOF

#Alternate DNS not working try with dnsmasq
# Add hostname to /etc/hosts
echo "127.0.0.1 $(hostname)" | sudo tee --append /etc/hosts

# dnsmasq config
echo "DNSStubListener=no" | sudo tee -a /etc/systemd/resolved.conf
#sudo cp /ops/config/10-consul.dnsmasq /etc/dnsmasq.d/10-consul
#sudo cp /ops/config/99-default.dnsmasq.$CLOUD /etc/dnsmasq.d/99-default
sudo mv /etc/resolv.conf /etc/resolv.conf.orig
grep -v "nameserver" /etc/resolv.conf.orig | grep -v -e"^#" | grep -v -e '^$' | sudo tee /etc/resolv.conf
echo "nameserver 127.0.0.1" | sudo tee -a /etc/resolv.conf
sudo systemctl restart systemd-resolved
sudo systemctl restart dnsmasq

# #TODO DNS working?
# sudo mkdir -p /etc/resolvconf/resolv.conf.d
# sudo cat > /etc/resolvconf/resolv.conf.d/consul.conf <<- EOF
# [Resolve]
# DNS=127.0.0.1
# Domains=~consul
# EOF
# sudo iptables --table nat --append OUTPUT --destination localhost --protocol udp --match udp --dport 53 --jump REDIRECT --to-ports 8600
# sudo iptables --table nat --append OUTPUT --destination localhost --protocol tcp --match tcp --dport 53 --jump REDIRECT --to-ports 8600
# sudo systemctl restart systemd-resolved


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

# sudo systemctl stop consul.service 
# sudo systemctl disable consul.service 
# sudo systemctl reload consul.service
# sudo systemctl enable consul.service
# sudo systemctl start consul.service

# sleep 5
# sudo systemctl stop nomad.service
# sudo systemctl disable nomad.service
# sudo systemctl reload nomad.service
# sudo systemctl enable nomad.service
# sudo systemctl start nomad.service

# sudo consul reload
# sleep 2
# sudo systemctl restart consul
# sleep 2
# sudo systemctl restart nomad
# echo "hello" > /ops/hello.txt
echo "Finished client setup"

sudo reboot
#echo "rebooting"
#cloud-boothook

#FILE=/home/ubuntu/reboot.txt

# if [ -f "$FILE" ]; then     
#   sudo rm -rf $FILE              
#   sudo reboot
# else
#   sudo touch $FILE
# fi
#curl http://169.254.169.254/latest/user-data


