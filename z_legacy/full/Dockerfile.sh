FROM ubuntu:18.04
CMD ["/bin/bash"]

RUN apt-get -y -qq update && apt-get -y -qq upgrade \
  && apt-get -y -qq install \
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
RUN sudo apt-get -y -qq install \
   curl \
   wget \
   gnupg2 \
   unzip \
   vim \
   iputils-ping
RUN echo "12 4" | sudo apt-get -y -qq install software-properties-common
RUN sudo apt-get -y -qq install \
   apt-transport-https \
   ca-certificates \
   gnupg-agent \
   python \
   git \
   python3-pip

RUN sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1


### NTP ###
ENV DEBIAN_FRONTEND=noninteractive
RUN sudo ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
   && sudo apt-get install -y tzdata \
   && sudo dpkg-reconfigure --frontend noninteractive tzdata \
   && sudo apt-get -y -qq update && sudo apt-get -y -qq upgrade \
   && sudo apt-get -y -qq install \
      ntp \
      ntpdate \
      ntpstat

### DOCKER ###
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
   && sudo add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
   && sudo apt-get -y -qq install \
     docker-ce \
     docker-ce-cli \
     containerd.io

RUN sudo ln -s /usr/bin/pip3 /usr/bin/pip

### K8S ###
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list \
   && sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6A030B21BA07F4FB
RUN sudo apt-get -y -qq update && sudo apt-get -y -qq upgrade
RUN sudo apt-get -y -qq install \
    kubectl \
    kubelet \
    kubeadm

### HELM ###
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
RUN cd -

### AWS CLI ###
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" \
  && unzip -qq /tmp/awscliv2.zip -d /tmp/ \
  && sudo /tmp//aws/install

### JAVA & DEV ###
RUN sudo apt-get -y -qq install \
   openjdk-8-jdk \
   maven \
   mysql-client

### NODE ###
RUN sudo apt-get -y -qq update && sudo apt-get -y -qq upgrade \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list \
  && sudo apt-get -y install \
    yarn


RUN touch /home/poweruser/.bashrc \
   && echo '### FUNCTIONS ###' >> /home/poweruser/.bashrc \
   && echo 'grep "DISTRIB_DESCRIPTION" /etc/lsb-release' >> /home/poweruser/.bashrc \
   && echo 'function showcolors { for bg in `seq 0 9`; do for fg in `seq 0 9`; do echo -n "`expr $fg` `expr $bg`: " && color `expr $fg` `expr $bg` "Tyler & Corey"; echo; done; done }'  >> /home/poweruser/.bashrc \
   && echo 'alias colors=showcolors' >> /home/poweruser/.bashrc \
   && echo 'function color  { echo -n "$(tput setaf $1;tput setab $2)${3}$(tput sgr 0) "; }' >> /home/poweruser/.bashrc \
   && echo 'function green  { color 4 2 "${*}"; }' >> /home/poweruser/.bashrc \
   && echo 'function yellow { color 0 3 "${*}"; }' >> /home/poweruser/.bashrc \
   && echo 'function red    { color 9 1 "${*}"; }' >> /home/poweruser/.bashrc \
   && echo 'function blue   { color 6 4 "${*}"; }' >> /home/poweruser/.bashrc \
   && echo 'function cyan   { color 9 6 "${*}"; }' >> /home/poweruser/.bashrc \
   && echo 'function grey   { color 0 7 "${*}"; }' >> /home/poweruser/.bashrc \
   && echo 'function pass   { echo; echo "$(green PASS: ${*})"; echo; }' >> /home/poweruser/.bashrc \
   && echo 'function warn   { echo; echo "$(yellow PASS: ${*})"; echo; }' >> /home/poweruser/.bashrc \
   && echo 'function fail   { echo; echo "$(red FAIL: ${*})"; echo; }' >> /home/poweruser/.bashrc \
   && echo 'function info   { echo; echo "$(grey INFO: ${*})"; echo; }' >> /home/poweruser/.bashrc \
   && echo 'blue "python:"; python --version' >> /home/poweruser/.bashrc \
   && echo 'blue "pip: "; pip --version' >> /home/poweruser/.bashrc

   RUN   echo '### NTP ###\n \
   echo "Doing NTP sync..."\n \
   sudo service ntp stop > /dev/null 2>&1\n \
   sudo ntpdate time.nist.gov && sudo service ntp start\n'
RUN   echo '### NTP ###' >> /home/poweruser/.bashrc \
   && echo 'echo "Doing NTP sync..."' >> /home/poweruser/.bashrc \
   && echo 'sudo service ntp stop > /dev/null 2>&1' >> /home/poweruser/.bashrc \
   && echo 'sudo ntpdate time.nist.gov && sudo service ntp start' >> /home/poweruser/.bashrc \
   && echo 'ntp_tries=8 && ntp_delay_seconds=4 && i=0' >> /home/poweruser/.bashrc \
   && echo 'while ! ntpstat > /dev/null 2>&1' >> /home/poweruser/.bashrc \
   && echo '   do sleep ${ntp_delay_seconds} && i=`expr ${i} + 1`' >> /home/poweruser/.bashrc \
   && echo '   if [ ${i} -ge ${ntp_tries} ]' >> /home/poweruser/.bashrc \
   && echo '      then yellow "NTP:" && echo bailing && break' >> /home/poweruser/.bashrc \
   && echo '   fi' >> /home/poweruser/.bashrc \
   && echo 'done' >> /home/poweruser/.bashrc \
   && echo 'if ntpstat > /dev/null 2>&1' >> /home/poweruser/.bashrc \
   && echo '   then green "NTP:" && ntpstat' >> /home/poweruser/.bashrc \
   && echo '   else red "NTP:" && echo "not synchronized"' >> /home/poweruser/.bashrc \
   && echo 'fi' >> /home/poweruser/.bashrc

RUN    echo '### DOCKER ###' >> /home/poweruser/.bashrc \
   && echo 'if ! sudo service docker status; then sudo service docker start; fi && sleep 2 && sudo service docker status' >> /home/poweruser/.bashrc \
   && echo 'cyan "Docker:"; docker --version' >> /home/poweruser/.bashrc \
   && echo 'if sudo docker run --rm hello-world 2> /dev/null | grep -o "Hello from Docker!"' >> /home/poweruser/.bashrc \
   && echo '   then pass "Docker Hello World"' >> /home/poweruser/.bashrc \
   && echo '   else fail "Docker Hello World"' >> /home/poweruser/.bashrc \
   && echo 'fi' >> /home/poweruser/.bashrc \
   && echo 'cyan "Docker Compose:"; docker-compose --version' >> /home/poweruser/.bashrc

RUN   echo '### K8S ###' >> /home/poweruser/.bashrc \
   && echo 'if command -v kubelet > /dev/null 2>&1; then cyan "kubelet:"; kubelet --version; else yellow "No kubelet"; fi;' >> /home/poweruser/.bashrc \
   && echo 'if command -v kubectl > /dev/null 2>&1; then cyan "kubectl:"; kubectl version --short --client; else yellow "No kubectl"; echo; fi;' >> /home/poweruser/.bashrc \
   && echo 'if command -v kubeadm > /dev/null 2>&1; then cyan "kubeadm:"; kubeadm version --output short; else yellow "No kubeadm"; echo; fi;' >> /home/poweruser/.bashrc \
   && echo 'if command -v eksctl > /dev/null 2>&1; then cyan "eksctl:"; eksctl version; else yellow "No eksctl"; echo; fi;' >> /home/poweruser/.bashrc \
   && echo 'cyan "AWS_CLI:"; /usr/local/bin/aws --version' >> /home/poweruser/.bashrc

RUN   echo '### HELM ###' >> /home/poweruser/.bashrc \
   && echo 'cyan "helm"; helm version --short' >> /home/poweruser/.bashrc

RUN   echo '### DEVTOOLS ###' >> /home/poweruser/.bashrc \
   && echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> /home/poweruser/.bashrc \
   && echo 'export M2_HOME=/usr/share/maven' >> /home/poweruser/.bashrc \
   && echo 'if command -v java > /dev/null 2>&1; then blue "java:"; java -version; else yellow "No Java"; fi; \
            if command -v javac > /dev/null 2>&1; then blue "javac:"; javac -version; else yellow "No JDK"; fi; \
            if command -v mvn > /dev/null 2>&1; then blue "maven"; mvn --version; else yellow "No Maven"; fi; \
            if command -v mysql > /dev/null 2>&1; then blue "mysql client:"; mysql --version; else yellow "No MySql Cient"; fi; \
            if [ -d /apache-activemq-5.16.0 ]; \
               then green "$(/apache-activemq-5.16.0/bin/activemq start)"; echo; \
               else grey "apache-activemq not mounted, not installed"; echo; \
            fi;' >> /home/poweruser/.bashrc

RUN   echo '### NODE ###' >> /home/poweruser/.bashrc \
   && git clone https://github.com/nvm-sh/nvm.git /home/poweruser/.nvm \
   && echo 'if  ! command -v nvm > /dev/null; then' >> /home/poweruser/.bashrc \
   && echo '. /home/poweruser/.nvm/nvm.sh' >> /home/poweruser/.bashrc \
   && echo 'export NVM_DIR="$HOME/.nvm"' >> /home/poweruser/.bashrc \
   && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> /home/poweruser/.bashrc \
   && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> /home/poweruser/.bashrc \
   && echo 'fi' >> /home/poweruser/.bashrc \
   && echo 'function nodever() { if [ ! -z $1 ]; then nvm install ${1} > /dev/null 2>&1 && nvm use ${_} > /dev/null 2>&1 && nvm alias default ${_} > /dev/null 2>&1; blue "Node:"; node -v; else echo usage: nodedef ver; fi; }' >> /home/poweruser/.bashrc \
   && echo 'if command -v nvm > /dev/null  && ! command -v node; then blue "nvm:";nvm install --lts' >> /home/poweruser/.bashrc \
   && echo 'else blue "Node:"; node -v ' >> /home/poweruser/.bashrc \
   && echo 'fi' >> /home/poweruser/.bashrc \
\
   && echo '### ###' >> /home/poweruser/.bashrc \
\
   && echo >>  /home/poweruser/.bashrc
