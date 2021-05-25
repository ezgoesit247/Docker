#!/bin/bash
FROM local/seed:ubuntu-20.04 as top

##  TAG1=ubuntu-20.04 && TAG2=ubuntu && . ./setenv && DEBUG=0 build --arg=LOCALHOMESAFE=${LOCALHOMESAFE} --arg=gitlogin=${CLOGIN} --arg=gituser=${CUSER} --arg=homepath=${HOMEPATH} --arg=SSH_PRIVATE_KEY=${KEYNAME} --key SSH_PRIVATE_KEY_STREAM ${KEYPATH} -t ${TAG1} -t=${TAG2}

##  . ./setenv && DEBUG=0 run --rm -I -e='DOCKER_ENV=developer'

##  CUSER=${GITUSER} && HOMEPATH=/home && CPATH=${HOMEPATH}/${CUSER} && DEBUG=0 run --rm -I -e='DOCKER_ENV=developer' -u ${CUSER} -w ${CPATH} local/gituser

FROM top as git
RUN apt-get -qq update \
&& apt-get -qq install \
git \
sudo \
&& apt-get clean


FROM git as user
ARG gituser=$gituser
ARG gitlogin=$gitlogin
ARG homepath=$homepath


ARG THISUSER=$gituser
ARG THISLOGIN=$gitlogin
ARG HOMEPATH=$homepath
ARG LOCALHOMESAFE=$LOCALHOMESAFE

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


ARG GITTOKEN=$USERHOME/.ssh/GITTOKEN
ENV GITTOKEN=$USERHOME/.ssh/GITTOKEN
COPY assets.docker/GITTOKEN $GITTOKEN
ARG HEROKUTOKEN=$USERHOME/.ssh/HEROKUTOKEN
ENV HEROKUTOKEN=$USERHOME/.ssh/HEROKUTOKEN
COPY assets.docker/HEROKUPASSWD $HEROKUTOKEN
ARG HEROKUPASSWD=$USERHOME/.ssh/HEROKUPASSWD
ENV HEROKUPASSWD=$USERHOME/.ssh/HEROKUPASSWD
COPY assets.docker/HEROKUPASSWD $HEROKUPASSWD
ENV GITUSER=$THISUSER
ENV GITLOGIN=$THISLOGIN
ENV HEROKULOGIN=$GITLOGIN
RUN chown $THISUSER:$THISUSER $GITTOKEN \
&& chown $THISUSER:$THISUSER $HEROKUTOKEN \
&& chmod 600 $GITTOKEN \
&& chmod 600 $HEROKUTOKEN \
&& chmod 600 $HEROKUPASSWD


USER $THISUSER

FROM user as end
RUN echo '### USER STUFF ###\n\
alias ls="ls -Altr --color=auto"\n\
export PS1="\\[\\033[1;34m\\]\\u\\[\\033[0m\\]@\\[\\033[1;31m\\]\\h:\\[\\033[0;37m\\]\\w\\[\\033[0m\\]\\$ " \n\
'\
>>$USERHOME/.bashrc
