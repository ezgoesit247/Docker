FROM local/centos-centos8 as layer1

# build --arg=gituser=${GITUSER} --arg=SSH_PRIVATE_KEY=${GITKEYNAME} --key SSH_PRIVATE_KEY_STREAM ~/.ssh/${GITKEYNAME} -t systemd centos8-developer
# docker exec -it $(docker run --hostname centos8 -d --rm --privileged --name centos8-developer -v=docker_vol:/docker_vol -v=/sys/fs/cgroup:/sys/fs/cgroup:ro local/centos8-developer:systemd) /bin/bash

RUN yum -y update \
&& yum install -y wget curl

FROM layer1 as layer2
RUN yum install -y git

FROM layer2 as layer3
RUN yum install -y yum-utils python3 \
&& yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
&& yum install -y -q docker-ce docker-ce-cli containerd.io \
&& curl -sL "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
&& chmod +x /usr/local/bin/docker-compose


FROM layer3 as layer4
RUN alternatives --set python /usr/bin/python3 \
&& yum install -y which vim

ENV GIT_SSH=/root/bin/git-ssh
ARG ROOT_SAFE_PATH=\\/root
ARG GIT_CONFIG=/root/.gitconfig
ARG KNOWN_HOSTS=/root/.ssh/known_hosts
COPY assets.docker/git-ssh $GIT_SSH
COPY assets.docker/.gitconfig $GIT_CONFIG
COPY assets.docker/known_hosts $KNOWN_HOSTS

ARG SSH_PRIVATE_KEY_PATH=/root/.ssh
ARG SSH_PRIVATE_KEY
ARG SSH_PRIVATE_KEY_STREAM
RUN echo "${SSH_PRIVATE_KEY_STREAM}" > $SSH_PRIVATE_KEY_PATH/$SSH_PRIVATE_KEY

RUN chmod 700 /root/.ssh \
&& chmod 755 /root/bin \
&& chmod 755 $GIT_SSH \
&& chmod 600 $KNOWN_HOSTS \
&& chmod 644 $GIT_CONFIG \
&& sed -i 's/\/Users\/***REMOVED***/'$ROOT_SAFE_PATH'/' $GIT_CONFIG \
&& chmod 600 $SSH_PRIVATE_KEY_PATH/$SSH_PRIVATE_KEY

FROM layer4 as layer5

ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

RUN yum clean all

FROM layer5 as last


RUN echo -e "\n\
function showcolors { for bg in \$(seq 0 9); do for fg in \$(seq 0 9); do echo -n \"\$(expr \${fg}) \$(expr \${bg}): \" && color \$(expr \${fg}) \$(expr \${bg}) \"Tyler & Corey\"; echo; done; done }\n\
alias colors=showcolors\n\
function color  { echo -n \"\$(tput setaf \$1;tput setab \$2)\${3}\$(tput sgr 0) \"; }\n\
function green  { color 4 2 \"\${*}\"; }\n\
function yellow { color 0 3 \"\${*}\"; }\n\
function red    { color 9 1 \"\${*}\"; }\n\
function blue   { color 6 4 \"\${*}\"; }\n\
function cyan   { color 4 6 \"\${*}\"; }\n\
function grey   { color 0 7 \"\${*}\"; }\n\
function pass   { echo \"\$(green PASS: \${*})\"; }\n\
function warn   { echo \"\$(yellow PASS: \${*})\"; }\n\
function fail   { echo \"\$(red FAIL: \${*})\"; }\n\
function info   { echo \"\$(grey INFO: \${*})\"; }\n\
function showalias { echo ${BASH_ALIASES[*]}; }\n\
\n\
function getservices { systemctl list-units --type=service; }\n\
function getactive { systemctl list-units --type=service --state=active; }\n\
function getinactive { systemctl list-units --type=service --state=inactive; }\n\
function getdead { getinactive|grep dead; }\n\
function getrunning { systemctl list-units --type=service --state=running; }\n\
function hello_docker {\n\
  if ! systemctl list-units --type=service --state=active|grep -q docker; then systemctl start docker; fi\n\
  if docker run --rm hello-world 2> /dev/null | grep -o \"Hello from Docker!\";\n\
    then pass \"Docker Hello World\";\n\
    else fail \"Docker Hello World\";\n\
  fi\n\
}\n\
blue \"python:\" && python --version\n\
cyan \"Docker:\" && docker --version\n\
cyan \"Docker Compose:\" && docker-compose --version\n\
if systemctl start docker.service\n\
  then cyan docker.service running: && hello_docker\n\
  else red docker.service not started:; fi\n\
\n\
"\
>> /etc/bashrc

VOLUME ["docker_vol"]
WORKDIR /docker_vol
