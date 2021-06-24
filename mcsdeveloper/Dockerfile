#!/bin/bash

##  . ./setenv && DEBUG=0 build --arg=THISUSER=${CUSER} --arg=HOMEDIR=${HOMEDIR}

##  docker run --rm -it -P --hostname ${APP} --user ${CUSER} -e DOCKER_ENV=${APP} -v ${HOME}/sandbox/assets.docker:/${HOMEDIR}/${CUSER}/local.assets -v ${HOME}/.m2:/${HOMEDIR}/${CUSER}/.m2 -v ${HOME}/.aws:/${HOMEDIR}/${CUSER}/.aws -v code-store:/${HOMEDIR}/${CUSER}/code-store -v ${DOCKER_ASSETS}:/${HOMEDIR}/${CUSER}/public.assets local/${APP}

FROM local/gituser:ubuntu-20.04 as top
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


FROM maven as azcli

#AZURE CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo /bin/bash
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor \
  | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/azure-cli.list
RUN sudo apt-get -y update && sudo apt-get -y install \
  azure-cli

FROM azcli as docker

### EMBED_DOCKER ###
RUN sudo apt-get -qq update && sudo apt-get install -qq apt-transport-https ca-certificates gnupg-agent software-properties-common && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && sudo apt-key fingerprint 0EBFCD88 && sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && sudo apt-get -qq update && sudo apt-get install -qq docker-ce docker-ce-cli containerd.io
RUN sudo usermod -a -G docker $(whoami);

FROM docker as dockercompose
### EMBED_DOCKER_COMPOSE ###
RUN sudo curl -sL https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose

FROM dockercompose as bashrc
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
RUN echo '### SHARED HISTORY ###\n\
if [ -d ${HOME}/public.assets/bash_history/ ]; then export HISTFILE="${HOME}/public.assets/bash_history/history.${DOCKER_ENV}"; fi && green "Shared bash history at:" && echo ${HISTFILE}\n\
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
RUN mkdir $USERHOME/code-store \
&& mkdir $USERHOME/scratch

VOLUME $USERHOME/code-store
VOLUME $USERHOME/scratch
