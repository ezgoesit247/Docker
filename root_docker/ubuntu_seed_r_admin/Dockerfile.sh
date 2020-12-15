FROM ubuntu:20.04
CMD ["/bin/bash"]

#GENERAL UTILITIES
RUN apt-get -y update && apt-get -y upgrade \
    && apt-get -y install \
      curl \
      gnupg \
      unzip \
      vim \
      mysql-client \
      iputils-ping \
      wget \
    && echo "12 4" | apt-get -y install software-properties-common \
    && apt-get -y install \
      apt-transport-https \
      ca-certificates \
      gnupg-agent \
      python \
      git \
      python3-pip

RUN ln -s /usr/bin/pip3 /usr/bin/pip

#PYTHON
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

###  && echo 'function green  { echo -n "$(tput setaf 4;tput setab 2)${*}$(tput sgr 0) "; }' >> /root/.bashrc \
###  && echo 'function yellow { echo -n "$(tput setaf 0;tput setab 3)${*}$(tput sgr 0) "; }' >> /root/.bashrc \
###  && echo 'function red    { echo -n "$(tput setaf 9;tput setab 1)${*}$(tput sgr 0) "; }' >> /root/.bashrc \
#ADD A BUNCH OF STUFF TO BASHRC
RUN echo 'grep "DISTRIB_DESCRIPTION" /etc/lsb-release' >> /root/.bashrc \
  && echo 'function showcolors { for bg in `seq 0 9`; do for fg in `seq 0 9`; do echo -n "`expr $fg` `expr $bg`: " && color `expr $fg` `expr $bg` "Tyler & Corey"; echo; done; done }'  >> /root/.bashrc \
  && echo 'alias colors=showcolors' >> /root/.bashrc \
  && echo 'function color  { echo -n "$(tput setaf $1;tput setab $2)${3}$(tput sgr 0) "; }' >> /root/.bashrc \
  && echo 'function green  { color 4 2 "${*}"; }' >> /root/.bashrc \
  && echo 'function yellow { color 0 3 "${*}"; }' >> /root/.bashrc \
  && echo 'function red    { color 9 1 "${*}"; }' >> /root/.bashrc \
  && echo 'function blue   { color 6 4 "${*}"; }' >> /root/.bashrc \
  && echo 'function cyan   { color 9 6 "${*}"; }' >> /root/.bashrc \
  && echo 'function grey   { color 0 7 "${*}"; }' >> /root/.bashrc \
  && echo 'function pass   { echo; echo "$(green PASS: ${*})"; echo; }' >> /root/.bashrc \
  && echo 'function warn   { echo; echo "$(yellow PASS: ${*})"; echo; }' >> /root/.bashrc \
  && echo 'function fail   { echo; echo "$(red FAIL: ${*})"; echo; }' >> /root/.bashrc \
  && echo 'function info   { echo; echo "$(grey INFO: ${*})"; echo; }' >> /root/.bashrc \
  && echo 'blue "mysql:"; mysql --version' >> /root/.bashrc \
  && echo 'blue "python:"; python --version' >> /root/.bashrc \
  && echo 'blue "pip: "; pip --version; echo' >> ~/.bashrc \
