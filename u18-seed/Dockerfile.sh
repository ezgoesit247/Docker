FROM local/u18-seedling


USER poweruser
WORKDIR /home/poweruser
RUN   echo 'alias ls="ls -Altr --color=auto"\n\
export PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]\$ " \n'\
 >> /home/poweruser/.bashrc


### GEN EDS- yarrgh ###
RUN sudo apt-get -qq purge openjdk-\*
RUN sudo apt-get -qq update \
   && sudo apt-get -qq install -y \
   curl \
   wget \
   gnupg2 \
   unzip \
   vim \
   iputils-ping \
   software-properties-common \
   apt-transport-https \
   ca-certificates \
   gnupg-agent \
   python \
   git \
   python3-pip
RUN sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
   && sudo ln -s /usr/bin/pip3 /usr/bin/pip

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
   blue "pip: "; pip --version'\
>> /home/poweruser/.bashrc

RUN   echo 'export HISTTIMEFORMAT="%F	%T	"\n'\
>> /home/poweruser/.bashrc


ARG DOCKER_ENV=default
ENV DOCKER_ENV=$DOCKER_ENV
RUN echo 'if [ -d ${HOME}/_assets/bash_history/ ]; then export HISTFILE="${HOME}/_assets/bash_history/history.'$DOCKER_ENV'"; fi'\
>> /home/poweruser/.bashrc


RUN sudo apt-get -qq clean
