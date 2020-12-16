FROM ubuntu:18.04
CMD ["/bin/bash"]

RUN apt-get -qq update \
  && apt-get -qq install \
    sudo
RUN echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
  && useradd -rm -s /bin/bash -d /home/poweruser -U -G sudo -u 1001 poweruser
USER poweruser
WORKDIR /home/poweruser
ENV DOCKER_ENV=default
RUN   echo 'clear\n \
if [ -d _assets/bash_history/ ]; then export HISTFILE="${HOME}/_assets/bash_history/history.${DOCKER_ENV}" && echo "Shared bash history at: ${HISTFILE}"; else echo "bash history not persisted: ${HISTFILE}"; fi\n \
export HISTTIMEFORMAT="%F	%T	"' >> /home/poweruser/.bashrc

### GEN EDS- yarrgh ###
RUN sudo apt-get -qq install \
   curl \
   wget \
   unzip \
   vim \
   iputils-ping
RUN echo "12 4" | sudo apt-get -qq install software-properties-common
RUN sudo apt-get -qq update \
  && sudo apt-get -qq install \
   apt-transport-https \
   ca-certificates \
   gnupg-agent \
   python \
   git \
   python3-pip
RUN   sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
RUN   sudo ln -s /usr/bin/pip3 /usr/bin/pip
RUN   echo '\n \
### FUNCTIONS ###\n \
grep "DISTRIB_DESCRIPTION" /etc/lsb-release\n \
function showcolors { for bg in `seq 0 9`; do for fg in `seq 0 9`; do echo -n "`expr $fg` `expr $bg`: " && color `expr $fg` `expr $bg` "Tyler & Corey"; echo; done; done }\n \
alias colors=showcolors\n \
function color  { echo -n "$(tput setaf $1;tput setab $2)${3}$(tput sgr 0) "; }\n \
function green  { color 4 2 "${*}"; }\n \
function yellow { color 0 3 "${*}"; }\n \
function red    { color 9 1 "${*}"; }\n \
function blue   { color 6 4 "${*}"; }\n \
function cyan   { color 9 6 "${*}"; }\n \
function grey   { color 0 7 "${*}"; }\n \
function pass   { echo "$(green PASS: ${*})"; }\n \
function warn   { echo "$(yellow PASS: ${*})"; }\n \
function fail   { echo "$(red FAIL: ${*})"; }\n \
function info   { echo "$(grey INFO: ${*})"; }\n \
blue "python:"; python --version\n \
blue "pip: "; pip --version' >> /home/poweruser/.bashrc


### NTP ###
ENV DEBIAN_FRONTEND=noninteractive
RUN sudo ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
   && sudo apt-get install -qq tzdata \
   && sudo dpkg-reconfigure --frontend noninteractive tzdata \
   && sudo apt-get -qq update \
   && sudo apt-get -qq install \
      ntp \
      ntpdate \
      ntpstat
RUN   echo '### NTP ###\n \
echo "Doing NTP sync..."\n \
sudo service ntp stop > /dev/null 2>&1\n \
sudo ntpdate time.nist.gov && sudo service ntp start\n \
ntp_tries=8 && ntp_delay_seconds=4 && i=0\n \
while ! ntpstat > /dev/null 2>&1\n \
   do sleep ${ntp_delay_seconds} && i=`expr ${i} + 1`\n \
   if [ ${i} -ge ${ntp_tries} ]\n \
      then yellow "NTP:" && echo bailing && break\n \
   fi\n \
done\n \
if ntpstat > /dev/null 2>&1\n \
   then green "NTP:" && ntpstat\n \
   else red "NTP:" && echo "not synchronized"\n \
fi' >>  /home/poweruser/.bashrc


### DOCKER ###
RUN sudo apt-get install -qq \
      apt-transport-https \
      ca-certificates \
      gnupg-agent \
      software-properties-common \
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
fi\n \
cyan "Docker Compose:"; docker-compose --version' >> /home/poweruser/.bashrc


### K8S ###
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
#RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6A030B21BA07F4FB
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
RUN echo waiting... && sleep 3 \
   && sudo apt-get -qq update \
   \
   && sudo apt-get -qq install \
    kubectl \
    kubelet \
    kubeadm \
    kubernetes-cni
RUN   echo '### K8S ###\n \
if command -v kubelet > /dev/null 2>&1; then cyan "kubelet:"; kubelet --version; else yellow "No kubelet"; echo; fi;\n \
if command -v kubectl > /dev/null 2>&1; then cyan "kubectl:"; kubectl version --short --client; else yellow "No kubectl"; echo; fi;\n \
if command -v kubeadm > /dev/null 2>&1; then cyan "kubeadm:"; kubeadm version --output short; else yellow "No kubeadm"; echo; fi;\n \
if command -v eksctl > /dev/null 2>&1; then cyan "eksctl:"; eksctl version; else yellow "No eksctl"; echo; fi;\n \
cyan "AWS_CLI:"; /usr/local/bin/aws --version' >> /home/poweruser/.bashrc

### HELM ###
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash \
   && cd -
RUN   echo '### HELM ###\n \
cyan "helm"; helm version --short' >> /home/poweruser/.bashrc


### AWS CLI ###
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" \
  && unzip -qq /tmp/awscliv2.zip -d /tmp/ \
  && sudo /tmp/aws/install \
   && echo 'cyan "AWS CLI:"; aws --version' >> /home/poweruser/.bashrc

### JAVA & DEV ###
RUN sudo apt-get -qq install \
   openjdk-8-jdk \
   maven \
   mysql-client
RUN   echo '### DEVTOOLS ###\n \
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64\n \
export M2_HOME=/usr/share/maven\n \
if command -v java > /dev/null 2>&1; then blue "java:"; java -version; else yellow "No Java"; fi;\n \
if command -v javac > /dev/null 2>&1; then blue "javac:"; javac -version; else yellow "No JDK"; fi;\n \
if command -v mvn > /dev/null 2>&1; then blue "maven"; mvn --version; else yellow "No Maven"; fi;\n \
if command -v mysql > /dev/null 2>&1; then blue "mysql client:"; mysql --version; else yellow "No MySql Cient"; fi;\n \
if [ -d /apache-activemq-5.16.0 ];\n \
   then green "$(/apache-activemq-5.16.0/bin/activemq start)"; echo;\n \
   else grey "apache-activemq not mounted, not installed"; echo;\n \
fi;' >> /home/poweruser/.bashrc

### NODE ###
RUN sudo apt-get -qq update \
   && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
   && echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list \
   && sudo apt-get -qq install \
      yarn \
   && git clone https://github.com/nvm-sh/nvm.git /home/poweruser/.nvm
RUN   echo '### NODE ###\n \
pushd .nvm && git pull && popd\n \
if  ! command -v nvm > /dev/null; then\n \
. /home/poweruser/.nvm/nvm.sh\n \
export NVM_DIR="$HOME/.nvm"\n \
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm\n \
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion\n \
fi\n \
function nodever() { if [ ! -z $1 ]; then nvm install ${1} > /dev/null 2>&1 && nvm use ${_} > /dev/null 2>&1 && nvm alias default ${_} > /dev/null 2>&1; blue "Node:"; node -v; else echo usage: nodedef ver; fi; }\n \
if command -v nvm > /dev/null  && ! command -v node; then blue "nvm:";nvm install --lts\n \
else blue "Node:"; node -v \n \
fi' >> /home/poweruser/.bashrc


#AZURE CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo /bin/bash \
&& curl -sL https://packages.microsoft.com/keys/microsoft.asc \
 | sudo gpg --dearmor \
 | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null \
&& echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/azure-cli.list \
&& sudo apt-get -qq update && sudo apt-get -qq install \
 azure-cli

#TERRAFORM
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - \
 && sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
 && sudo apt-get install terraform \
 && sudo terraform -install-autocomplete

RUN sudo mkdir /terraform-docker-demo /home/poweruser/terraform \
 && sudo mkdir /learn-terraform-aws-instance \
 && sudo mkdir /learn-terraform-azure \
 && git clone https://github.com/hashicorp/learn-terraform-provision-eks-cluster \
 && git clone https://github.com/hashicorp/learn-terraform-provision-aks-cluster

COPY ./terraform/* /home/poweruser/terraform/

RUN echo 'cyan "Azure CLI:"; /usr/bin/az --version' >> /home/poweruser/.bashrc \
 && echo 'f1="/home/poweruser/terraform/terraform.aws.run.sh"; if [ -r $f1 ]; then info "#NORUN: . $f1"; else echo "$f1 Not Found"; fi' >> /home/poweruser/.bashrc \
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



### ANSIBLE ###
#RUN pip install virtualenv
#RUN    echo '### ANSIBLE ###\n \
#python -m virtualenv ansible\n \
#source ansible/bin/activate\n \
#python -m pip install ansible' >> /home/poweruser/.bashrc

### LINUX KERNEL HACING ###
#RUN sudo apt-get -qq update \
#  && sudo apt-get -qq install build-essential dkms
