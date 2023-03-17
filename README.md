# Nomad Multi-Region Deployment

## Description

This repo contains Terraform code for deploying Nomad clusters across multiple cloud regions.

## Table of Contents
- [Nomad Multi-Region Deployment](#nomad-multi-region-deployment)
  - [Description](#description)
  - [Table of Contents](#table-of-contents)
  - [Architecture Diagram](#architecture-diagram)
  - [Usage](#usage)
    - [Authenticate to AWS using Environment Variables](#authenticate-to-aws-using-environment-variables)
    - [Add ssh-key to AWS Regions for EC2 SSH Access](#add-ssh-key-to-aws-regions-for-ec2-ssh-access)
    - [Authenticate to HCP Packer via Environment Variables](#authenticate-to-hcp-packer-via-environment-variables)
    - [Build AMI using Packer and copy AMI to regions](#build-ami-using-packer-and-copy-ami-to-regions)
    - [This iteration associated to the Fingerprint is complete.  Change the Packer Build Fingerprint](#this-iteration-associated-to-the-fingerprint-is-complete--change-the-packer-build-fingerprint)
    - [Deploy Infrastructure with Terraform](#deploy-infrastructure-with-terraform)
    - [Output Example](#output-example)
    - [Connecting to Instances](#connecting-to-instances)
    - [Federate Nomad Clusters](#federate-nomad-clusters)
    - [Troubleshooting](#troubleshooting)


## Architecture Diagram
![Nomad Multi Region](./assets/nomad-multi-region.png "Nomad Multi Region")

## Usage

### Authenticate to AWS using Environment Variables
```
export AWS_ACCESS_KEY_ID=ASIA3PL2TGENYK26B...
export AWS_SECRET_ACCESS_KEY=nAjFUOdynJ+OH...
export AWS_SESSION_TOKEN=IQoJb3JpZ2luX2VjE...
```

### Add ssh-key to AWS Regions for EC2 SSH Access

```
ssh-keygen -y -f ahar-keypair-2023.pem > $HOME/.ssh/id_rsa_MyKeyPair.pub

AWS_REGIONS=("us-east-1" "us-east-2" "us-west-1" "us-west-2")
for each_region in ${AWS_REGIONS} ; do aws ec2 import-key-pair --key-name ahar-keypair-2024 --public-key-material fileb://$HOME/.ssh/id_rsa_MyKeyPair.pub --region $each_region ; done

#Alternate method to populate keys across all regions
#
#AWS_REGIONS="$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)"
#uncomment next line if using zsh shell
#setopt shwordsplit
```

### Authenticate to HCP Packer via Environment Variables

```
export HCP_CLIENT_ID=xVRieBpO9KY...
export HCP_CLIENT_SECRET=kVAq8HVMu...
```

### Build AMI using Packer and copy AMI to regions

```
cd packer
packer init image.pkr.hcl
packer build -var-file=variables-packer.hcl image.pkr.hcl
cd ..
```

### This iteration associated to the Fingerprint is complete.  Change the Packer Build Fingerprint
```
#Note: This is Useful when you want to deploy a new packer image without a new git commit (must modify image.pkr.hcl)
export HCP_PACKER_BUILD_FINGERPRINT=$(openssl sha1 image.pkr.hcl | awk '{print $NF}' )
```

### Deploy Infrastructure with Terraform
```
#terraform destroy --auto-approve
terraform apply --auto-approve
rm nomad.token
rm nomad2.token
rm nomad1.token
./post-setup.sh
```

### Output Example
```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

consul_bootstrap_token_secret = "8f966fde72-d76a-2f4d-5b97-e7c9fafa8d"
region_1_nomad_ui = "http://35.221.181.49:4646"
region_1_server_ip = "35.221.181.49"
region_1_vpc_id = "vpc-01g98f754c309be2d"
region_2_nomad_ui = "http://19.221.215.253:4646"
region_2_server_ip = "19.221.215.253"
region_2_vpc_id = "vpc-0fd824260c5035522"

```

### Connecting to Instances
```
ssh -i ahar-keypair-2023.pem ubuntu@$(terraform output -raw "region_1_server_ip")
```

### Federate Nomad Clusters
```
nomad server join $(terraform output -raw "region_2_server_ip")
```

### Troubleshooting
```
#View Log Files on Nomad Server/Client Nodes
cat /var/log/syslog

#Transit Gateway Troubleshooting
[Troubleshooting Transit Gateway Routing](https://aws.amazon.com/premiumsupport/knowledge-center/transit-gateway-fix-vpc-connection/)

#Add permission to anonymous Consul token
export CONSUL_HTTP_TOKEN=8f966e72-d76a-2f4d-5b97-e7c9928d
consul acl token update -accessor-id=00000000-0000-0000-0000-000000000002 -append-policy-name=nomad-auto-join
```
