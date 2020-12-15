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
