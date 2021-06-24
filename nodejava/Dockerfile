#!/bin/bash

##  . ./setenv && DEBUG=0 build --arg=THISUSER=${CUSER} --arg=HOMEDIR=${HOMEDIR}

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


FROM maven as userstuff

FROM userstuff as bashrc

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
