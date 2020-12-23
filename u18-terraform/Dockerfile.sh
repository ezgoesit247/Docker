FROM local/u18-seed
### DOCKER ###
RUN sudo apt-get install -qq \
      apt-transport-https \
      ca-certificates \
      gnupg-agent \
   && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
   && sudo apt-key fingerprint 0EBFCD88 \
   && sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
   && sudo apt-get update \
   && sudo apt-get install -qq \
      docker-ce \
      docker-ce-cli \
      containerd.io
RUN    echo '### DOCKER ###\n \
if ! sudo service docker status; then sudo service docker start; fi && sleep 2 && sudo service docker status\n \
cyan "Docker:"; docker --version\n \
if sudo docker run --rm hello-world 2> /dev/null | grep -o "Hello from Docker!"\n \
  then pass "Docker Hello World"\n \
  else fail "Docker Hello World"\n \
fi' >> /home/poweruser/.bashrc

### DOCKER COMPOSE ###
RUN sudo curl -sL https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose\
   && sudo chmod +x /usr/local/bin/docker-compose
RUN    echo '### DOCKER ###\n \
cyan "Docker Compose:"; docker-compose --version' >> /home/poweruser/.bashrc


### AWS CLI ###
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" \
  && unzip -qq /tmp/awscliv2.zip -d /tmp/ \
  && sudo /tmp/aws/install \
  && echo 'cyan "AWS CLI:"; aws --version' >> /home/poweruser/.bashrc

#AZURE CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo /bin/bash \
&& curl -sL https://packages.microsoft.com/keys/microsoft.asc \
 | sudo gpg --dearmor \
 | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null \
&& echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/azure-cli.list \
&& sudo apt-get -qq update && sudo apt-get -qq install \
 azure-cli \
&& echo 'cyan "Azure CLI:"; /usr/bin/az --version' >> /home/poweruser/.bashrc

#TERRAFORM
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - \
 && sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
 && sudo apt-get install terraform \
 && sudo terraform -install-autocomplete
RUN echo 'cyan "Terraform: " && terraform --version' >> /home/poweruser/.bashrc

RUN sudo mkdir /terraform-docker-demo /home/poweruser/terraform \
 && sudo mkdir /learn-terraform-aws-instance \
 && sudo mkdir /learn-terraform-azure \
 && git clone https://github.com/hashicorp/learn-terraform-provision-eks-cluster \
 && git clone https://github.com/hashicorp/learn-terraform-provision-aks-cluster

COPY ./terraform/* /home/poweruser/terraform/

RUN echo 'f1="/home/poweruser/terraform/terraform.aws.run.sh"; if [ -r $f1 ]; then info "#NORUN: . $f1"; else echo "$f1 Not Found"; fi' >> /home/poweruser/.bashrc \
 && echo 'f2="/home/poweruser/terraform/terraform.az.run.sh"; if [ -r $f2 ]; then info "#NORUN: . $f2"; else echo "$f2 Not Found"; fi' >> /home/poweruser/.bashrc \
 && echo 'f3="/home/poweruser/terraform/terraform.aws.eks-cluster.run.sh"; if [ -r $f3 ]; then info "#NORUN: . $f3"; else echo "$f3 Not Found"; fi' >> /home/poweruser/.bashrc \
 && echo 'f4="/home/poweruser/terraform/terraform.az.aks-cluster.run.sh"; if [ -r $f4 ]; then info "#NORUN: . $f4"; else echo "$f4 Not Found"; fi' >> /home/poweruser/.bashrc

RUN echo '#NORUN . $f1' >> /home/poweruser/.bashrc \
 &&  echo '#NORUN . $f2' >> /home/poweruser/.bashrc \
 &&  echo '#NORUN . $f3' >> /home/poweruser/.bashrc \
 &&  echo '#NORUN . $f4' >> /home/poweruser/.bashrc


### COMPOSE
RUN sudo curl -sL https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose \
   && sudo chmod +x /usr/local/bin/docker-compose

ENV DOCKER_ENV=terraform

#RUN sudo apt-get -y -qq update \
#   && sudo apt-get -y install build-essential dkms

#https://www.vagrantup.com/docs/providers/virtualbox/boxes
#apt-get install linux-headers-$(uname -r) build-essential dkms
