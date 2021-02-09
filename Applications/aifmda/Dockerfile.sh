FROM local/u18-java8 as intermediate

RUN apt-get -qq update \
&& apt-get install -qq \
sudo \
git \
mysql-client \
&& apt-get -qq clean

ENV GIT_SSH=/root/bin/git-ssh
ARG GIT_CONFIG=/root/.gitconfig
ARG KNOWN_HOSTS=/root/.ssh/known_hosts
ARG SSH_PRIVATE_KEY=/root/.ssh/***REMOVED***
ARG SSH_PRIVATE_KEY_STREAM

RUN mkdir /root/bin \
&& mkdir /root/.ssh

COPY assets.docker/git-ssh $GIT_SSH
COPY assets.docker/.gitconfig $GIT_CONFIG
COPY assets.docker/known_hosts $KNOWN_HOSTS
COPY assets.docker/***REMOVED*** $SSH_PRIVATE_KEY

RUN chmod 700 /root/.ssh \
&& chmod 755 /root/bin \
&& chmod 755 $GIT_SSH \
&& chmod 600 $KNOWN_HOSTS \
&& chmod 644 $GIT_CONFIG \
&& sed -i 's/\/Users\/***REMOVED***/\/root/' $GIT_CONFIG \
\
#&& echo "${SSH_PRIVATE_KEY_STREAM}" > $SSH_PRIVATE_KEY \
&& chmod 600 $SSH_PRIVATE_KEY

RUN echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
&& useradd -ms /bin/bash -d /home/poweruser -U poweruser

RUN git clone git@github.com:***REMOVED***/MDA /mda \
&& chown -R poweruser:poweruser /mda
# VOLUME /mda


RUN   echo 'alias ls="ls -Altr --color=auto"\n\
export PS1="${debian_chroot:+($debian_chroot)}\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]\$ " \n\
'\
>> /home/poweruser/.bashrc

RUN   echo '\n\
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
>> /home/poweruser/.bashrc

RUN   echo 'export HISTTIMEFORMAT="%F	%T	"\n\
'\
>> /home/poweruser/.bashrc

RUN echo '\n\
### DEVTOOLS ###\n\
if command -v java > /dev/null 2>&1; then blue "java:"; java -version; else yellow "No Java"; echo; fi;\n\
if command -v javac > /dev/null 2>&1; then blue "javac:"; javac -version; else yellow "No JDK"; echo; fi;\n\
if command -v mvn > /dev/null 2>&1; then blue "maven"; mvn --version; else yellow "No Maven"; echo; fi;\n\
if command -v mysql > /dev/null 2>&1; then blue "mysql client:"; mysql --version; else yellow "No MySql Cient"; echo; fi;\n\
'\
>> /home/poweruser/.bashrc

RUN   echo '\n\
if [ -d /apache-activemq-5.16.0 ];\n\
then green "$(/apache-activemq-5.16.0/bin/activemq start)"; echo;\n\
else grey "apache-activemq not mounted, not installed"; echo;\n\
fi;\n\
#ln -fsn local.assets/.gitconfig;\n\
#ln -fsn local.assets/.gitignore_global;\n\
'\
>> /home/poweruser/.bashrc

RUN apt-get -qq clean

USER poweruser
WORKDIR /home/poweruser
ENV DOCKER_ENV=aifmda
ENV DOCKER_ENV=$DOCKER_ENV


RUN echo 'if [ -d ${HOME}/_assets/bash_history/ ]; then export HISTFILE="${HOME}/_assets/bash_history/history.'$DOCKER_ENV'"; fi && green "Shared bash history at: " && echo ${HISTFILE}\n\
'\
>> /home/poweruser/.bashrc
