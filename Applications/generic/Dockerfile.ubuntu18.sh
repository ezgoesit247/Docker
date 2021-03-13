FROM local/u18-java8 as top

#####   APP=<APP NAME>
#####   build --arg=SSH_PRIVATE_KEY=${GITKEYNAME} --key SSH_PRIVATE_KEY_STREAM ~/.ssh/${GITKEYNAME} --arg=APP=${APP} -f Dockerfile.ubuntu18.sh -t=${APP} Applications/generic
#####   run --rm --env=dev --purpose=sandbox --container=${APP} --app=${APP} local/${APP}:ubuntu18

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

ARG UNAME=default_virtual
ARG UDIR=/home
ARG UDIRPATH=$UDIR/$UNAME
ARG UDIR_SAFE_PATH=\\/home\\/$UNAME

RUN apt-get -qq install sudo \
&& useradd -ms /bin/bash -d $UDIRPATH -U $UNAME \
&& echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
&& mkdir $UDIRPATH/bin

FROM top as setup

ARG APP
VOLUME /$APP
RUN git clone git@github.com:***REMOVED***/$APP /$APP \
&& chown -R $UNAME:$UNAME /$APP /$APP/.git \
&& rm -rf $GIT_CONFIG /root/.ssh /root/bin

RUN apt-get -qq clean

FROM setup

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

RUN apt-get -qq clean

USER $UNAME
WORKDIR $UDIRPATH
ARG DOCKER_ENV=$APP
ENV DOCKER_ENV=$DOCKER_ENV

RUN sudo ln -fsn /$APP ${UDIRPATH}/$APP \
&& sudo chown -R $UNAME:$UNAME $UDIRPATH \
&& echo '\
alias ls="ls -Altr --color=auto" \n\
export PS1="\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]\$ "\n\
export HISTTIMEFORMAT="%F	%T	"\n\
if [ -d ${HOME}/public.assets/bash_history/ ]; then export HISTFILE="${HOME}/public.assets/bash_history/history.'$DOCKER_ENV'"; fi && green "Shared bash history at: " && echo ${HISTFILE}\n\
pushd /'$APP' >/dev/null 2>&1 && git pull 2>/dev/null && popd >/dev/null 2>&1 || popd >/dev/null 2>&1\n\
'\
>> /home/$UNAME/.bashrc
