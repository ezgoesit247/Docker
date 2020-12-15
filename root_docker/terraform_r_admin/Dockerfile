FROM docker_admin

RUN apt-get -y update && apt-get -y upgrade

#AZURE CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | /bin/bash \
&& curl -sL https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor \
  | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null \
&& echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
| tee /etc/apt/sources.list.d/azure-cli.list \
&& apt-get -y update && apt-get -y install \
  azure-cli

#TERRAFORM
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
  && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  && apt-get install terraform \
  && terraform -install-autocomplete

RUN mkdir /terraform-docker-demo /root/terraform \
  && mkdir /learn-terraform-aws-instance \
  && mkdir /learn-terraform-azure \
  && git clone https://github.com/hashicorp/learn-terraform-provision-eks-cluster \
  && git clone https://github.com/hashicorp/learn-terraform-provision-aks-cluster

COPY ./terraform/* /root/terraform/

RUN echo 'color 9 6 "AZ_CLI:"; /usr/bin/az --version' >> /root/.bashrc \
  && echo 'f1="/root/terraform/terraform.aws.run.sh"; if [ -r $f1 ]; then info "#NORUN: . $f1"; else echo "$f1 Not Found"; fi' >> /root/.bashrc \
  && echo 'f2="/root/terraform/terraform.az.run.sh"; if [ -r $f2 ]; then info "#NORUN: . $f2"; else echo "$f2 Not Found"; fi' >> /root/.bashrc \
  && echo 'f3="/root/terraform/terraform.aws.eks-cluster.run.sh"; if [ -r $f3 ]; then info "#NORUN: . $f3"; else echo "$f3 Not Found"; fi' >> /root/.bashrc \
  && echo 'f4="/root/terraform/terraform.az.aks-cluster.run.sh"; if [ -r $f4 ]; then info "#NORUN: . $f4"; else echo "$f4 Not Found"; fi' >> /root/.bashrc

RUN echo '#NORUN . $f1' >> /root/.bashrc \
  &&  echo '#NORUN . $f2' >> /root/.bashrc \
  &&  echo '#NORUN . $f3' >> /root/.bashrc \
  &&  echo '#NORUN . $f4' >> /root/.bashrc
