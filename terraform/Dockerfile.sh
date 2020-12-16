FROM docker

RUN apt-get -y -qq update \
  && apt-get -y -qq install \
    sudo
RUN echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
  && useradd -rm -s /bin/bash -d /home/poweruser -U -G sudo -u 1001 poweruser
USER poweruser
WORKDIR /home/poweruser
ENV DOCKER_ENV=terraform
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
RUN sudo apt-get -y -qq update \
  && sudo apt-get -y -qq install \
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
function pass   { echo; echo "$(green PASS: ${*})"; echo; }\n \
function warn   { echo; echo "$(yellow PASS: ${*})"; echo; }\n \
function fail   { echo; echo "$(red FAIL: ${*})"; echo; }\n \
function info   { echo; echo "$(grey INFO: ${*})"; echo; }\n \
blue "python:"; python --version\n \
blue "pip: "; pip --version' >> /home/poweruser/.bashrc


### DOCKER ###
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -
RUN sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
RUN echo waiting... \
   && sudo apt-get -y -qq update \
   && sudo apt-get -y -qq install \
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

#RUN sudo apt-get -y -qq update \
#   && sudo apt-get -y install build-essential dkms

#https://www.vagrantup.com/docs/providers/virtualbox/boxes
#apt-get install linux-headers-$(uname -r) build-essential dkms
