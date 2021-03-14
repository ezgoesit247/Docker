FROM local/c7-systemd as tmp1
#  build --arg=DH=${DOCKERHUB_USER} --arg=DP=${DOCKERHUB_PWD} c7-docker
#  docker run -d --rm --privileged -v=docker_vol:/docker_vol -v /sys/fs/cgroup:/sys/fs/cgroup:ro local/c7-docker
#  docker exec -it <GUID_RETURNED_ABOVE> sh
#
### WRAPPED INTO A ONE-LINER:
#  docker exec -it $(docker run -d --rm --privileged --name c7-docker -v=docker_vol:/docker_vol -v /sys/fs/cgroup:/sys/fs/cgroup:ro local/c7-docker) /bin/bash

RUN yum -y update \
&& yum install -y -q yum-utils \
&& yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
&& yum install -y -q docker-ce docker-ce-cli containerd.io
RUN curl -sL "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
&& chmod +x /usr/local/bin/docker-compose

FROM tmp1 as tmp2

RUN yum install -y -q git which sudo python3

### DO YUMS BEFORE CHANGING PYTHON ###
#RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

ARG DH
ARG DP
ENV DOCKERHUB_USER=$DH
ENV DOCKERHUB_PWD=$DP
RUN echo 'if ! systemctl start docker.service; then echo "docker.service not started"; fi; \
### FUNCTIONS ###; \
function showcolors { for bg in `seq 0 9`; do for fg in `seq 0 9`; do echo -n "`expr $fg` `expr $bg`: " && color `expr $fg` `expr $bg` "Tyler & Corey"; echo; done; done }; \
alias colors=showcolors; \
function color  { echo -n "$(tput setaf $1;tput setab $2)${3}$(tput sgr 0) "; }; \
function green  { color 4 2 "${*}"; }; \
function yellow { color 0 3 "${*}"; }; \
function red    { color 9 1 "${*}"; }; \
function blue   { color 6 4 "${*}"; }; \
function cyan   { color 4 6 "${*}"; }; \
function grey   { color 0 7 "${*}"; }; \
function pass   { echo "$(green PASS: ${*})"; }; \
function warn   { echo "$(yellow PASS: ${*})"; }; \
function fail   { echo "$(red FAIL: ${*})"; }; \
function info   { echo "$(grey INFO: ${*})"; }; \
function showalias { echo ${BASH_ALIASES[*]}; }; \
function getservices { systemctl list-units --type=service; }; \
function getactive { systemctl list-units --type=service --state=active; }; \
function getinactive { systemctl list-units --type=service --state=inactive; }; \
function getdead { getinactive|grep dead; }; \
function getrunning { systemctl list-units --type=service --state=running; }; \
### DOCKER ###; \
function hello_docker { \
  if ! systemctl list-units --type=service --state=active|grep -q docker; then systemctl start docker; fi; \
  if docker run --rm hello-world 2> /dev/null | grep -o "Hello from Docker!"; \
    then pass "Docker Hello World"; \
    else fail "Docker Hello World"; \
  fi; \
}; \
blue "python:"; python --version; \
blue "pip: "; pip --version; \
cyan "Docker:"; docker --version; \
cyan "Docker Compose:"; docker-compose --version; \
hello_docker; \
docker login -u ${DOCKERHUB_USER} --password-stdin <<<`echo ${DOCKERHUB_PWD}` \
' \
>> /etc/bashrc

CMD ["/sbin/init"]
VOLUME ["docker_vol"]
WORKDIR /docker_vol

RUN yum clean all
