#!/bin/bash

[ -f ~/assets/terraform/main.aws.tf ] && \
  cp ~/assets/terraform/main.aws.tf /terraform-docker-demo/main.tf && \
  cd /terraform-docker-demo/

terraform init
echo "yes" | terraform apply
if [ -n "`curl localhost:8000 | grep -o 'successfully installed'`" ]
  then echo;echo $(tput setaf 4;tput setab 2)'*** Terraform Docker Passed <<<'$(tput sgr 0); echo; else echo;echo $(tput setaf 9;tput setab 1)'*** Terraform Docker Failed <<<'$(tput sgr 0);echo;
fi
sleep 1
echo "yes" | terraform destroy


[ -f ~/assets/terraform/example.aws.tf ] && \
  cp ~/assets/terraform/example.aws.tf /learn-terraform-aws-instance/example.tf && \
  cd /learn-terraform-aws-instance/

#WORKS JUST FINE -- JUST DON'T WANT IT RUN
#terraform init
#terraform fmt
#terraform validate
#echo yes | terraform apply
#echo yes | terraform destroy
