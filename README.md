# Nomad multi-region deployment

## Diagram
![Nomad Multi Region](./assets/nomad-multi-region.png "Nomad Multi Region")

## This repo contains code for deploying Nomad clusters across multiple cloud regions

## Usage

```
#Add ssh-key to AWS regions
ssh-keygen -y -f ahar-keypair-2023.pem > $HOME/.ssh/id_rsa_MyKeyPair.pub
AWS_REGIONS="$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)"]
#uncomment if using zsh shell
setopt shwordsplit
for each_region in ${AWS_REGIONS} ; do aws ec2 import-key-pair --key-name ahar-keypair-2024 --public-key-material fileb://$HOME/.ssh/id_rsa_MyKeyPair.pub --region $each_region ; done
```
```
#Build AMI using Packer
cd packer
packer init image.pkr.hcl
packer build -var-file=variables-packer.hcl image.pkr.hcl
cd ..
terraform destroy --auto-approve
terraform apply --auto-approve
rm nomad.token
rm nomad2.token
rm nomad1.token
./post-setup.sh
#ssh -i ahar-keypair-2023.pem ubuntu@$(terraform output -raw "region_1_server_ip")

```

```
sed -i 's/kv\/db\/postgres\/product-db-creds/database\/creds\/products-api/g' /root/policies/products-api-policy.hcl
```