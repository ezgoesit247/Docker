FROM local/u18-java8

##### BUILD
#####   APP=generic && \
#####   USER=generic && \
#####   build \
#####   --arg=localuser=${USER} \
#####   --arg=app=${APP}

##### DATABASE
#####   APP=generic && \
#####   run \
#####   --env=dev  \
#####   --purpose=database  \
#####   --app=${APP}  \
#####   mysql/mysql-server:5.7

##### APPDEV
#####   APP=generic && \
#####   CREATE_VOL_OPTIONAL=-v=${APP}:/usr/local/${APP} && \
#####   APP=generic && \
#####   run \
#####   --rm \
#####   --env=dev \
#####   --purpose=sandbox \
#####   --container=${APP} \
#####   --app=${APP} \
#####   ${CREATE_VOL_OPTIONAL} \
#####   local/${APP}

RUN apt-get -qq update \
&& apt-get install -qq \
git \
mysql-client \
&& apt-get -qq clean

ARG R=root
ARG RDIR=
ARG KY=
ARG RDIRPATH=/root
ARG RDIR_SAFE_PATH=\\/root

ENV GIT_SSH=$RDIRPATH/bin/git-ssh
ARG GIT_CONFIG=$RDIRPATH/.gitconfig
ARG KNOWN_HOSTS=$RDIRPATH/.ssh/known_hosts
ARG SSH_PRIVATE_KEY=$RDIRPATH/.ssh/$KY
ARG SSH_PRIVATE_KEY_STREAM

RUN mkdir $RDIRPATH/bin \
&& mkdir $RDIRPATH/.ssh

COPY assets.docker/git-ssh $GIT_SSH
COPY assets.docker/.gitconfig $GIT_CONFIG
COPY assets.docker/known_hosts $KNOWN_HOSTS
COPY assets.docker/***REMOVED*** $SSH_PRIVATE_KEY

RUN chmod 700 $RDIRPATH/.ssh \
&& chmod 755 $RDIRPATH/bin \
&& chmod 755 $GIT_SSH \
&& chmod 600 $KNOWN_HOSTS \
&& chmod 644 $GIT_CONFIG \
&& sed -i 's/\/Users\/***REMOVED***/'$RDIR_SAFE_PATH'/' $GIT_CONFIG \
\
#&& echo "${SSH_PRIVATE_KEY_STREAM}" > $SSH_PRIVATE_KEY \
&& chmod 600 $SSH_PRIVATE_KEY

ARG app
ARG localuser
ARG U=$localuser
ARG UDIR=/home
ARG UDIRPATH=$UDIR/$U

VOLUME /$app
#VOLUME /$app
RUN git clone git@github.com:***REMOVED***/$app /$app
RUN ln -fsn /$app /usr/local/$app
RUN rm -rf $GIT_CONFIG $RDIRPATH/.ssh/* $RDIRPATH/bin


RUN apt-get -qq install sudo \
&& useradd -ms /bin/bash -d $UDIRPATH -U $U \
&& echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


RUN chown -R $U:$U $app $app/.git

USER $U
WORKDIR $UDIRPATH
ENV DOCKER_ENV=$app
ENV DOCKER_ENV=$DOCKER_ENV

ENV GIT_SSH=$UDIRPATH/local.assets/git-ssh
ARG GIT_CONFIG=$UDIRPATH/.gitconfig
ARG KNOWN_HOSTS=$UDIRPATH/.ssh/known_hosts
ARG SSH_PRIVATE_KEY_STREAM


COPY assets.docker/.gitconfig $GIT_CONFIG

RUN sudo chmod 644 $GIT_CONFIG
RUN sed -i 's/\/Users\/***REMOVED***/'$UDIR_SAFE_PATH'/' $GIT_CONFIG

#&& echo "${SSH_PRIVATE_KEY_STREAM}" > $SSH_PRIVATE_KEY \
#RUN sudo chown -R $U:$U $UDIR/*

RUN sudo apt-get -qq clean
RUN sudo ln -fsn /usr/local/$app ${UDIRPATH}/Application
RUN sudo chown -R $U:$U $UDIRPATH

RUN echo '\
for d in $(ls -A1 ~'$U'); do sudo chown '$U':'$U' ~'$U'/${d}; done \n\
#sudo chown '$U':root /usr/local/'$app' \n\
alias ls="ls -Altr --color=auto" \n\
export PS1="${debian_chroot:+($debian_chroot)}\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]\$ " \n\
export HISTTIMEFORMAT="%F	%T	"\n\
if [ -d ${HOME}/public.assets/bash_history/ ]; then export HISTFILE="${HOME}/public.assets/bash_history/history.'$DOCKER_ENV'"; fi && green "Shared bash history at: " && echo ${HISTFILE}\n\
pushd /'$app' >/dev/null 2>&1 && git pull 2>/dev/null && popd >/dev/null 2>&1 || popd >/dev/null 2>&1\n\
'\
>> ${UDIRPATH}/.bashrc


RUN sudo apt-get -qq clean
