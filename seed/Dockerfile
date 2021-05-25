#!/bin/bash
FROM ubuntu:20.04 as seedling
CMD [ "/bin/bash" ]

RUN apt-get -qq update \
   && apt-get -qq install \
      curl \
      wget \
      unzip \
      vim

### GEN EDS- yarrgh ###
RUN apt-get -qq update \
   && apt-get -qq install -y \
   gnupg2 \
   iputils-ping \
   software-properties-common \
   apt-transport-https \
   ca-certificates \
   gnupg-agent

FROM seedling as python
RUN apt-get -qq install -y \
python \
python3-pip \
&& apt-get -qq clean

FROM python as py2
RUN update-alternatives --install /usr/bin/python python /usr/bin/python2 2 \
&& update-alternatives --install /usr/bin/python python /usr/bin/python3 3 \
&& update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 3

FROM py2 as stuff
ARG GREEN="'\e[32m%s\e[m'"
ARG YELLOW="'\e[33m%s\e[m'"
ARG BLUE="'\e[34m%s\e[m'"
ARG NEWLINE="'\\\n'"
ARG SPACE="' '"
ARG COLOR_NORMAL="'\\\e[0m'"
RUN echo '\n\
### FUNCTIONS ###\n\
#https://askubuntu.com/questions/558280/changing-colour-of-text-and-background-of-terminal
function shades {\n\
  for((i=16; i<256; i++)); do\n\
      printf "\\e[48;5;${i}m%03d" $i;\n\
      printf "\\e[0m";\n\
      [ ! $((($i - 15) % 6)) -eq 0 ] && printf '$SPACE' || printf '$NEWLINE'\n\
  done\n\
}\n\
function changetext { printf "\e[$1;$2;$3m${*:4}\e[0m " ; }\n\
function showcolors { for bg in `seq 0 9`; do for fg in `seq 0 9`; do echo -n "`expr $fg` `expr $bg`: " && color `expr $fg` `expr $bg` "Tyler & Corey"; echo; done; done }\n\
alias colors=showcolors\n\
function color  { echo -n "$(tput setaf $1;tput setab $2)${3}$(tput sgr 0) "; }\n\
function println { printf "$1\n" "${@:2}"; }\n\
function green { changetext 0 34 42 $* ; }\n\
function yellow { changetext 0 31 43 $* ; }\n\
function blue { changetext 0 36 44 $*; }\n\
function cyan { changetext 0 0 46 $*; }\n\
function grey { changetext 1 39 100 $* ; }\n\
green "$(grep DISTRIB_DESCRIPTION /etc/lsb-release)" && echo\n\
blue "python:" && python --version\n\
blue "pip:" && pip --version\
'\
>>/etc/bash.bashrc

FROM stuff as rootstuff
RUN echo '### ROOT STUFF ###\n\
alias ls="ls -Altr --color=auto"\n\
export PS1="\\[\\033[1;32m\\]\\u\\[\\033[0m\\]@\\[\\033[1;31m\\]\\h:\\[\\033[0;37m\\]\\w\\[\\033[0m\\]\\$ " \n\
export HISTTIMEFORMAT="%FT%T\t"\n\
'\
>>/root/.bashrc
