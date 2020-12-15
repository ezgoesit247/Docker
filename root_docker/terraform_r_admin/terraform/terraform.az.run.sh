#!/bin/bash

[ -f ~/assets/terraform/main.az.tf ] && \
  cp ~/assets/terraform/main.az.tf /learn-terraform-azure/main.tf && \
  cd /learn-terraform-azure

#BROWSWER STEP >>> WOAH >> DOMAIN TRUST IS GOOD
az login

terraform init
terraform plan
echo yes | terraform apply
terraform show
terraform state list
echo yes | terraform destroy
