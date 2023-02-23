# nomad-multi-region

```
#Add ssh-key to AWS regions
ssh-keygen -y -f ahar-keypair-2024.pem > $HOME/.ssh/id_rsa_MyKeyPair.pub
AWS_REGIONS="$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)"]
#uncomment if using zsh shell
#setopt shwordsplit
for each_region in ${AWS_REGIONS} ; do aws ec2 import-key-pair --key-name ahar-keypair-2024 --public-key-material fileb://$HOME/.ssh/id_rsa_MyKeyPair.pub --region $each_region ; done
```
```
#Build AMI using Packer
cd packer
packer init image.pkr.hcl
packer build -var-file=variables-packer.hcl image.pkr.hcl
#take ami output from packer, modify terraform.tfvarsfile ami parameter
#ami = "ami-08d3ec81c1a2c0953"
#AMI_ID=$(jq -r '.builds[-1].artifact_id' packer-manifest.json | cut -d ":" -f2)
#echo $AMI_ID
```

```
terraform apply --auto-approve
rm nomad.token
./post-setup.sh
#ssh -i ahar-keypair-2023.pem ubuntu@44.204.251.229
#nomad acl bootstrap
#Secret ID    = 8ab64db9-4298-d8c2-49
```

```
sed -i 's/kv\/db\/postgres\/product-db-creds/database\/creds\/products-api/g' /root/policies/products-api-policy.hcl
```