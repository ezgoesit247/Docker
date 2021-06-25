#!/bin/bash

##  . ./setenv && DEBUG=0 build --arg=THISUSER=${CUSER} --arg=HOMEDIR=${HOMEDIR} --arg=LOCALHOMESAFE=${LOCALHOMESAFE} --arg=gitlogin=${CLOGIN} --arg=gituser=${CUSER} --arg=homepath=${HOMEPATH} --arg=SSH_PRIVATE_KEY=${KEYNAME} --key SSH_PRIVATE_KEY_STREAM ${KEYPATH}

##  docker run --rm -it -P --hostname ${APP} --user ${CUSER} -e DOCKER_ENV=${APP} -v ${HOME}/sandbox/assets.docker:/${HOMEDIR}/${CUSER}/local.assets -v ${HOME}/.m2:/${HOMEDIR}/${CUSER}/.m2 -v ${HOME}/.aws:/${HOMEDIR}/${CUSER}/.aws -v code-store:/${HOMEDIR}/${CUSER}/code-store -v ${DOCKER_ASSETS}:/${HOMEDIR}/${CUSER}/public.assets local/${APP}

FROM local/seed:ubuntu-20.04 as top2

##  . ./setenv && DEBUG=0 build

##  . ./setenv && DEBUG=0 run --rm -I -e='DOCKER_ENV=developer'

##  CUSER=${GITUSER} && HOMEPATH=/home && CPATH=${HOMEPATH}/${CUSER} && DEBUG=0 run --rm -I -e='DOCKER_ENV=developer' -u ${CUSER} -w ${CPATH} local/gituser

FROM top2 as git2
RUN apt-get -qq update \
&& apt-get -qq install \
git \
sudo \
&& apt-get clean


FROM git2 as user2
ARG gituser
ARG gitlogin
ARG homepath
ARG LOCALHOMESAFE


ARG THISUSER=$gituser
ARG THISLOGIN=$gitlogin
ARG HOMEPATH=$homepath

# THESE SHOULD NOT *need* TO CHANGE
ARG SAFEPATH=\\$HOMEPATH
ARG USERHOME=$HOMEPATH/$THISUSER
ARG SAFEHOME=$SAFEPATH\\/$THISUSER
ENV GIT_SSH=$USERHOME/bin/git-ssh
ARG GIT_CONFIG=$USERHOME/.gitconfig
ARG KNOWN_HOSTS=$USERHOME/.ssh/known_hosts
ARG GIT_IGNORE_GLOBAL=$USERHOME/.gitignore_global

ARG SSH_PRIVATE_KEY_PATH=$USERHOME/.ssh
ARG SSH_PRIVATE_KEY
ARG SSH_PRIVATE_KEY_STREAM


RUN groupadd -g 1000 $THISUSER \
&& useradd -d $USERHOME -s /bin/bash -m $THISUSER -u 1000 -g 1000 \
&& echo "ALL ALL=(ALL) NOPASSWD: ALL"\
>>/etc/sudoers


COPY assets.docker/git-ssh $GIT_SSH
COPY assets.docker/.gitconfig $GIT_CONFIG
COPY assets.docker/known_hosts $KNOWN_HOSTS
COPY assets.docker/.gitignore_global $GIT_IGNORE_GLOBAL
RUN echo "${SSH_PRIVATE_KEY_STREAM}" > $SSH_PRIVATE_KEY_PATH/$SSH_PRIVATE_KEY

RUN chmod 700 $USERHOME/.ssh \
&& chmod 755 $USERHOME/bin \
&& chmod 755 $GIT_SSH \
&& chmod 600 $KNOWN_HOSTS \
&& chmod 644 $GIT_CONFIG \
&& chmod 644 $GIT_IGNORE_GLOBAL \
&& sed -i 's/'$LOCALHOMESAFE'/'$SAFEHOME'/' $GIT_CONFIG \
&& chmod 600 $SSH_PRIVATE_KEY_PATH/$SSH_PRIVATE_KEY \
&& chown -R $THISUSER:$THISUSER $USERHOME


ENV GITUSER=$THISUSER
ENV GITLOGIN=$THISLOGIN

ARG GITTOKEN=$USERHOME/.ssh/GITTOKEN
ENV GITTOKEN=$GITTOKEN
COPY assets.docker/GITTOKEN $GITTOKEN
RUN chown $THISUSER:$THISUSER $GITTOKEN \
&& chmod 600 $GITTOKEN

ARG DOCKERHUBUSER=$USERHOME/.ssh/DOCKERHUBUSER
ENV DOCKERHUBUSER=$DOCKERHUBUSER
COPY assets.docker/DOCKERHUBUSER $DOCKERHUBUSER
ARG DOCKERHUBTOKEN=$USERHOME/.ssh/DOCKERHUBTOKEN
ENV DOCKERHUBTOKEN=$DOCKERHUBTOKEN
COPY assets.docker/DOCKERHUBTOKEN $DOCKERHUBTOKEN

RUN sudo chown $THISUSER:$THISUSER $DOCKERHUBUSER \
&& sudo chmod 600 $DOCKERHUBUSER \
&& sudo chown $THISUSER:$THISUSER $DOCKERHUBTOKEN \
&& sudo chmod 600 $DOCKERHUBTOKEN


USER $THISUSER

FROM user2 as gituser
RUN echo '### USER STUFF ###\n\
alias ls="ls -Altr --color=auto"\n\
export PS1="\\[\\033[1;34m\\]\\u\\[\\033[0m\\]@\\[\\033[1;31m\\]\\h:\\[\\033[0;37m\\]\\w\\[\\033[0m\\]\\$ " \n\
'\
>>$USERHOME/.bashrc

FROM gituser as top
ARG THISUSER
ARG HOMEDIR
ARG USERHOME=/$HOMEDIR/$THISUSER


FROM top as nodeinstall

### NVM *must have* NVM_DIR
ENV NVM_DIR=$USERHOME/.nvm
ENV NVM_HOME=$NVM_DIR
RUN git clone https://github.com/nvm-sh/nvm.git $NVM_DIR

RUN echo $([ -s $NVM_DIR/nvm.sh ] && . $NVM_DIR/nvm.sh && [ -s $NVM_DIR/bash_completion ] && . $NVM_DIR/bash_completion && nvm install --lts)



FROM nodeinstall as tzdata
RUN sudo ln -fs /usr/share/zoneinfo/CST6CDT /etc/localtime \
&& sudo DEBIAN_FRONTEND=noninteractive \
apt-get install -y --no-install-recommends \
tzdata



FROM tzdata as jdk8
ARG JDK8_TAR=jdk-1.8.tar.gz
ARG JAVA8=/usr/local/jdk1.8
ENV JAVA_HOME=$JAVA8
#ENV PATH="$PATH:$JAVA_HOME/bin"
COPY assets.docker/$JDK8_TAR $JDK8_TAR
RUN tar zxf $JDK8_TAR -C /tmp \
&& sudo mv /tmp/jdk* ${JAVA8} \
&& sudo rm -rf $JDK8_TAR


FROM jdk8 as jdk11
ARG JDK11_TAR=jdk-11.tar.gz
ARG JAVA11=/usr/local/jdk11
ENV JAVA_HOME=$JAVA11
ENV PATH="$PATH:$JAVA_HOME/bin"
COPY assets.docker/$JDK11_TAR $JDK11_TAR
RUN tar zxf $JDK11_TAR -C /tmp \
&& sudo mv /tmp/jdk* ${JAVA11} \
&& sudo rm -rf $JDK11_TAR


FROM jdk11 as go
#ARG GO_TAR=go1.tar.gz
#ARG GO_HOME=/usr/local/go
#ENV GO_HOME=$GO_HOME
#ENV PATH="$PATH:$GO_HOME/bin"
#COPY assets.docker/$GO_TAR $GO_TAR
#RUN tar zxf $GO_TAR -C /tmp \
#&& mv /tmp/go* ${GO_HOME} \
#&& rm -rf $GO_TAR

FROM go as maven
ARG M2_TAR=apache-maven-3.tar.gz
ARG M2_HOME=/usr/local/maven
ENV M2_HOME=$M2_HOME
ENV PATH="$PATH:$M2_HOME/bin"
COPY assets.docker/$M2_TAR $M2_TAR
RUN tar zxf $M2_TAR -C /tmp \
&& sudo mv /tmp/apache-maven-3* ${M2_HOME} \
&& sudo rm -rf $M2_TAR

FROM maven as docker
### EMBED_DOCKER ###
RUN sudo apt-get -qq update && sudo apt-get install -qq apt-transport-https ca-certificates gnupg-agent software-properties-common && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && sudo apt-key fingerprint 0EBFCD88 && sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && sudo apt-get -qq update && sudo apt-get install -qq docker-ce docker-ce-cli containerd.io
RUN sudo usermod -a -G docker $(whoami);

FROM docker as dockercompose
### EMBED_DOCKER_COMPOSE ###
RUN sudo curl -sL https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose


FROM dockercompose as azcli
#AZURE CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo /bin/bash
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor \
  | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/azure-cli.list
RUN sudo apt-get -y update && sudo apt-get -y install \
  azure-cli

RUN echo '\n\
blue "AZ CLI:" && az -v\n\
'\
>>$USERHOME/.bashrc



FROM azcli as powershell
#SEE https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1#ubuntu-2004
RUN sudo apt-get update \
&& sudo wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb \
&& sudo dpkg -i packages-microsoft-prod.deb \
&& sudo apt-get update \
&& sudo add-apt-repository universe \
&& sudo apt-get install -y \
powershell

RUN echo '\n\
blue "PowerShell:" && pwsh -v\n\
'\
>>$USERHOME/.bashrc

FROM powershell as bashrc
RUN echo '### NODE VIA NVM ###\n\
cyan "Updating nvm:" && echo $(cd .nvm && git pull)\n\
if  ! command -v nvm >/dev/null; then\n\
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm\n\
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion\n\
fi\n\
#echo $PATH\n\
function nodever() {\n\
  if [ ! -z $1 ]; then\n\
    nvm install ${1} >/dev/null 2>&1 && nvm use ${_} > /dev/null 2>&1\\\n\
      && nvm alias default ${_} > /dev/null 2>&1; blue "Node:"; node -v; else\n\
    yellow "Use nodever to install or switch node versions:" && echo -e "\\n usage: nodever [ver]"\n\
    blue "Node:" && node -v\n\
    blue "npm:" && npm -v\n\
    blue "nvm:" && nvm -v\n\
  fi\n\
}\n\
nodever\n\
'\
>>$USERHOME/.bashrc

ARG PACKAGE="function PACKAGE { echo \$(node -p \"try { require('./package.json').name } catch(e) {}\"); }"
RUN echo '\n\
'$PACKAGE'\n\
'\
>>$USERHOME/.bashrc

RUN echo '### YARN (NEEDS NVM) ###\n\
  if ! command -v yarn >/dev/null 2>&1; then grey "Getting yarn: " && npm install --global yarn >/dev/null; fi\n\
'\
>>$USERHOME/.bashrc


ARG DOCKER_ENV
ENV DOCKER_ENV=$DOCKER_ENV
RUN echo '### PERSIST HISTORY ###\n\
if touch ${HOME}/history/${DOCKER_ENV}.history;then export HISTFILE="${HOME}/history/${DOCKER_ENV}.history" && green "Persistent history at:" && echo ${HISTFILE};else yellow History not persistent;fi \n\
'\
>>$USERHOME/.bashrc

ARG line="set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab autoindent"
ARG line="$line\nset number"
ARG line="$line\nset nocompatible"
ARG line="$line\nsyntax on"
ARG line="$line\ncolo pablo"
ARG line="$line\nset cursorline"
ARG line="$line\nhi CursorLine   cterm=NONE ctermbg=NONE ctermfg=NONE"
ARG line="$line\nhi CursorLineNr   cterm=NONE ctermbg=36 ctermfg=NONE"
RUN echo "$line" >$USERHOME/.vimrc

WORKDIR $USERHOME
RUN mkdir $USERHOME/code-store
VOLUME $USERHOME/code-store

RUN mkdir $USERHOME/history
VOLUME $USERHOME/history
