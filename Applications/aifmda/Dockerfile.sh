FROM local/u18-java8 as top

#####   KY=${GIT_KEY_NAME} && build --arg=KY=${KY}
#####   run --rm --env=dev --purpose=sandbox --container=aifmda --app=aifmda -v=aifmda_app:/usr/local/aifmda local/aifmda

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
COPY assets.docker/$KY $SSH_PRIVATE_KEY

RUN chmod 700 $RDIRPATH/.ssh \
&& chmod 755 $RDIRPATH/bin \
&& chmod 755 $GIT_SSH \
&& chmod 600 $KNOWN_HOSTS \
&& chmod 644 $GIT_CONFIG \
&& sed -i 's/\/Users\/***REMOVED***/'$RDIR_SAFE_PATH'/' $GIT_CONFIG \
\
#&& echo "${SSH_PRIVATE_KEY_STREAM}" > $SSH_PRIVATE_KEY \
&& chmod 600 $SSH_PRIVATE_KEY

ARG U=poweruser
ARG UDIR=/home
ARG UDIRPATH=$UDIR/$U
ARG UDIR_SAFE_PATH=\\/home\\/poweruser


RUN apt-get -qq install sudo \
&& useradd -ms /bin/bash -d $UDIRPATH -U $U \
&& echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
&& mkdir $UDIRPATH/bin


VOLUME /mda
RUN git clone git@github.com:***REMOVED***/MDA /mda \
&& chown -R $U:$U /mda /mda/.git \
&& rm -rf $GIT_CONFIG $RDIRPATH/.ssh $RDIRPATH/bin


FROM top


#FROM local/u18-java8
#VOLUME /code
#COPY --from=intermediate /mda /code


ENV GIT_SSH=$UDIRPATH/bin/git-ssh
ARG GIT_CONFIG=$UDIRPATH/.gitconfig
ARG KNOWN_HOSTS=$UDIRPATH/.ssh/known_hosts
ARG SSH_PRIVATE_KEY=$UDIRPATH/.ssh/$KY
ARG SSH_PRIVATE_KEY_STREAM



COPY assets.docker/git-ssh $GIT_SSH
COPY assets.docker/.gitconfig $GIT_CONFIG
COPY assets.docker/known_hosts $KNOWN_HOSTS
COPY assets.docker/$KY $SSH_PRIVATE_KEY

RUN chmod 700 $UDIRPATH/.ssh \
&& chmod 755 $UDIRPATH/bin \
&& chmod 755 $GIT_SSH \
&& chmod 600 $KNOWN_HOSTS \
&& chmod 644 $GIT_CONFIG \
&& sed -i 's/\/Users\/***REMOVED***/'$UDIR_SAFE_PATH'/' $GIT_CONFIG \
\
#&& echo "${SSH_PRIVATE_KEY_STREAM}" > $SSH_PRIVATE_KEY \
&& chmod 600 $SSH_PRIVATE_KEY \
&& chown -R $U:$U $UDIR/*



RUN apt-get -qq clean

USER $U
WORKDIR $UDIRPATH
ENV DOCKER_ENV=aifmda
ENV DOCKER_ENV=$DOCKER_ENV

VOLUME aifmda


RUN \
sudo ln -fsn /aifmda /usr/local/aifmda \
&& sudo ln -fsn /usr/local/aifmda ${UDIRPATH}/Application

RUN \
ln -fsn /mda $UDIRPATH \
&& sudo chown -R $U:$U $UDIRPATH \
&& echo '\
for d in $(ls -A1 ~'$U'); do sudo chown '$U':'$U' ~'$U'/${d}; done \n\
sudo chown '$U':root /usr/local/aifmda \n\
alias ls="ls -Altr --color=auto" \n\
export PS1="${debian_chroot:+($debian_chroot)}\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]\$ " \n\
export HISTTIMEFORMAT="%F	%T	"\n\
if [ -d ${HOME}/public_assets/bash_history/ ]; then export HISTFILE="${HOME}/_assets/bash_history/history.'$DOCKER_ENV'"; fi && green "Shared bash history at: " && echo ${HISTFILE}\n\
pushd /mda >/dev/null 2>&1 && git pull 2>/dev/null && popd >/dev/null 2>&1 || popd >/dev/null 2>&1\n\
'\
>> /home/poweruser/.bashrc
