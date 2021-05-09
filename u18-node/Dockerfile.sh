FROM local/u18-java8 as top0
### NODE ###
RUN apt-get update -qq
RUN apt-get install -qq gnupg2
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
&& apt-get install -qq \
yarn


##  CUSER=${GITUSER} && KEYNAME=${GITKEYNAME} && KEYPATH=${GITKEYPATH} && APP=node

##  build --arg=APP=${APP} --arg=gituser=${CUSER} --arg=SSH_PRIVATE_KEY=${KEYNAME} --key SSH_PRIVATE_KEY_STREAM ${KEYPATH} u18-node

##  run --rm --env=dev local/u18-node

FROM top0 as top
RUN apt-get -qq update \
&& apt-get install -qq \
git

ENV GIT_SSH=/root/bin/git-ssh
ARG ROOT_SAFE_PATH=\\/root
ARG GIT_CONFIG=/root/.gitconfig
ARG KNOWN_HOSTS=/root/.ssh/known_hosts
COPY assets.docker/git-ssh $GIT_SSH
COPY assets.docker/.gitconfig $GIT_CONFIG
COPY assets.docker/known_hosts $KNOWN_HOSTS

ARG SSH_PRIVATE_KEY_PATH=/root/.ssh
ARG SSH_PRIVATE_KEY
ARG SSH_PRIVATE_KEY_STREAM
RUN echo "${SSH_PRIVATE_KEY_STREAM}" > $SSH_PRIVATE_KEY_PATH/$SSH_PRIVATE_KEY

RUN chmod 700 /root/.ssh \
&& chmod 755 /root/bin \
&& chmod 755 $GIT_SSH \
&& chmod 600 $KNOWN_HOSTS \
&& chmod 644 $GIT_CONFIG \
&& sed -i 's/\/Users\/***REMOVED***/'$ROOT_SAFE_PATH'/' $GIT_CONFIG \
&& chmod 600 $SSH_PRIVATE_KEY_PATH/$SSH_PRIVATE_KEY

ARG UNAME=poweruser
ARG UDIR=/home
ARG UDIRPATH=$UDIR/$UNAME
ARG UDIR_SAFE_PATH=\\/home\\/$UNAME

RUN apt-get -qq install sudo \
&& useradd -ms /bin/bash -d $UDIRPATH -U $UNAME \
&& echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
&& mkdir $UDIRPATH/bin


RUN apt-get -qq clean

FROM top as gitcode

#ARG gituser
#ARG APP=aifmda
#VOLUME /$APP
#RUN git clone git@github.com:$gituser/$APP /$APP \
#&& chown -R $UNAME:$UNAME /$APP /$APP/.git \
#&& rm -rf $GIT_CONFIG /root/.ssh /root/bin

FROM gitcode as go
ARG GO_HOME=/usr/local/go
ARG GO_INSTALL_PATH=/usr/local
ENV GO_HOME=$GO_HOME
COPY assets.docker/go1.tar.gz go.tar.gz

RUN tar -zxf go.tar.gz \
&& mv go $GO_INSTALL_PATH \
&& rm -rf go.tar.gz
#RUN apt-get install -qq \
#mysql-client \
#&& apt-get -qq clean

FROM go as setup

ENV GIT_SSH=$UDIRPATH/bin/git-ssh
ARG GIT_CONFIG=$UDIRPATH/.gitconfig
ARG KNOWN_HOSTS=$UDIRPATH/.ssh/known_hosts

COPY assets.docker/git-ssh $GIT_SSH
COPY assets.docker/.gitconfig $GIT_CONFIG
COPY assets.docker/known_hosts $KNOWN_HOSTS

RUN chmod 755 $UDIRPATH/bin \
&& chmod 755 $GIT_SSH \
&& chmod 600 $KNOWN_HOSTS \
&& chmod 644 $GIT_CONFIG \
&& sed -i 's/\/Users\/***REMOVED***/'$UDIR_SAFE_PATH'/' $GIT_CONFIG \
&& chown -R $UNAME:$UNAME $UDIR/*

USER $UNAME
WORKDIR $UDIRPATH
ARG APP
ENV DOCKER_ENV=$APP

#RUN sudo ln -fsn /$APP ${UDIRPATH}/$APP \
#&& sudo chown -R $UNAME:$UNAME $UDIRPATH \
RUN echo "\
export PS1=\"\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]\$ \"\n\
export HISTTIMEFORMAT=\"%F	%T	\"\n\
alias ls=\"ls -Altr --color=auto\" \n\
if [ -d ${HOME}/public.assets/bash_history/ ]; then export HISTFILE=\"${HOME}/public.assets/bash_history/history.${DOCKER_ENV}\"; fi && green \"Shared bash history at: \" && echo \${HISTFILE}\n\
pushd /${APP} >/dev/null 2>&1 && git pull 2>/dev/null && popd >/dev/null 2>&1 || popd >/dev/null 2>&1\n\
"\
>>/home/$UNAME/.bashrc



############################################

FROM setup as tmp2

RUN git clone https://github.com/nvm-sh/nvm.git $UDIRPATH/.nvm

FROM tmp2 as node

ENV GO_HOME=$GO_HOME
ENV PATH="$PATH:$GO_HOME/bin"


RUN echo '### NODE ###\n\
pushd /home/poweruser/.nvm\n\
git pull\n\
popd\n\
if  ! command -v nvm >/dev/null; then\n\
. /home/poweruser/.nvm/nvm.sh\n\
export NVM_DIR="$HOME/.nvm"\n\
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm\n\
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion\n\
fi\n\
function nodever() { if [ ! -z $1 ]; then nvm install ${1} >/dev/null 2>&1 && nvm use ${_} > /dev/null 2>&1 && nvm alias default ${_} > /dev/null 2>&1; blue "Node:"; node -v; else echo -e " usage: nodedef ver\n\tinstall or switch node versions, currently:"; blue "Node:"; node -v; fi; }\n\
if command -v nvm >/dev/null  && ! command -v node; then blue "nvm:";nvm install --lts; fi\n\
blue "Node:"; node -v \n\
'\
>>${UDIRPATH}/.bashrc



RUN echo '\n\
if command -v go > /dev/null 2>&1; then blue "Google Go:" && go version; else yellow "No Google Go"; echo; fi;\n\
'\
>>${UDIRPATH}/.bashrc

from node as vimrc
ARG VIMRC="set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab autoindent\nset number\nset nocompatible\nsyntax on\nset cursorline\nhi CursorLine   cterm=NONE ctermbg=236 ctermfg=NONE\nhi CursorLineNr   cterm=NONE ctermbg=36 ctermfg=NONE"
RUN echo "${VIMRC}" >$UDIRPATH/.vimrc
