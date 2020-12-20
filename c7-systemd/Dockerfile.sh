FROM local/c7-systemd
### RUN CONTAINER WITH THIS COMMAND:
#  docker run --privileged -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro --rm c7-systemd
# THEN CONNECT WITH THIS COMMAND:
#  docker exec -it <GUID_RETURNED_ABOVE> sh
#
### WRAPPED INTO A ONE-LINER:
#  docker exec -it `docker run --privileged -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name systemd c7-systemd` /bin/bash

RUN yum -y update \
   && yum install -y -q yum-utils python3 \
   && yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
   && yum install -y -q docker-ce docker-ce-cli containerd.io
RUN curl -sL "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
   && chmod +x /usr/local/bin/docker-compose

RUN echo 'if ! systemctl start docker.service; then echo "docker.service not started"; fi; \
### FUNCTIONS ###; \
cat /etc/centos-release; \
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
blue "python:"; python --version; \
blue "pip: "; pip --version; \
### DOCKER ###; \
if ! systemctl list-units --type=service --state=active|grep -q docker; then systemctl start docker; fi; \
cyan "Docker:"; docker --version; \
cyan "Docker Compose:"; docker-compose --version; \
if docker run --rm hello-world 2> /dev/null | grep -o "Hello from Docker!"; \
  then pass "Docker Hello World"; \
  else fail "Docker Hello World"; \
fi;' >> /etc/bashrc

RUN yum install -y -q git which

### DO YUMS BEFORE CHANGING PYTHON ###
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

CMD ["/sbin/init"]
