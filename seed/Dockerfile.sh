FROM local/seedling:ubuntu-20.04 as top

### GEN EDS- yarrgh ###
RUN apt-get -qq update \
   && apt-get -qq install -y \
   gnupg2 \
   iputils-ping \
   software-properties-common \
   apt-transport-https \
   ca-certificates \
   gnupg-agent

RUN echo '\n\
### FUNCTIONS ###\n\
grep "DISTRIB_DESCRIPTION" /etc/lsb-release\n\
function showcolors { for bg in `seq 0 9`; do for fg in `seq 0 9`; do echo -n "`expr $fg` `expr $bg`: " && color `expr $fg` `expr $bg` "Tyler & Corey"; echo; done; done }\n\
alias colors=showcolors\n\
function color  { echo -n "$(tput setaf $1;tput setab $2)${3}$(tput sgr 0) "; }\n\
function green  { color 4 2 "${*}"; }\n\
function yellow { color 0 3 "${*}"; }\n\
function red    { color 9 1 "${*}"; }\n\
function blue   { color 6 4 "${*}"; }\n\
function cyan   { color 9 6 "${*}"; }\n\
function grey   { color 0 7 "${*}"; }\n\
function pass   { echo; echo "$(green PASS: ${*})"; echo; }\n\
function warn   { echo; echo "$(yellow PASS: ${*})"; echo; }\n\
function fail   { echo; echo "$(red FAIL: ${*})"; echo; }\n\
function info   { echo; echo "$(grey INFO: ${*})"; echo; }\n\
blue "python:"; python --version\n\
blue "pip: "; pip --version\
'\
>> /etc/bash.bashrc

RUN apt-get -qq clean

FROM top as bottom
RUN apt-get -qq install -y \
python \
python3-pip \
&& apt-get -qq clean
