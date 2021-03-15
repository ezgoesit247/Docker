FROM local/centos-centos8 as top

#####   APP=<APP NAME>
#####   build --arg=gituser=${GITUSER} --arg=SSH_PRIVATE_KEY=${GITKEYNAME} --key SSH_PRIVATE_KEY_STREAM ~/.ssh/${GITKEYNAME} --arg=app=${APP} -f Dockerfile.centos8.sh -t=${APP} Applications/generic

#####   run --rm --env=dev --purpose=sandbox --container=${APP} --app=${APP} -v=${APP}:/${APP} local/${APP}:centos8

#####   run --env=dev --purpose=database --app=${APP} mysql/mysql-server:5.7

RUN yum update -y \
&& yum install -y \
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

RUN yum install -y sudo \
&& useradd -ms /bin/bash -d $UDIRPATH -U $UNAME \
&& echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
&& mkdir $UDIRPATH/bin

FROM top as code

ARG gituser
ARG app
VOLUME /$app
RUN git clone git@github.com:$gituser/$app /$app \
&& chown -R $UNAME:$UNAME /$app /$app/.git \
&& rm -rf $GIT_CONFIG /root/.ssh /root/bin

FROM code as setup
### DO BIG THINGS ###

#RUN yum install -y \
#mysql \
#&& yum clean all

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

USER $UNAME
WORKDIR $UDIRPATH
ARG DOCKER_ENV=$app
ENV DOCKER_ENV=$DOCKER_ENV
ENV PS1="\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]\$ "
ENV HISTTIMEFORMAT="%F	%T	"

RUN sudo ln -fsn /$app ${UDIRPATH}/$app \
&& sudo chown -R $UNAME:$UNAME $UDIRPATH \
&& echo -e "\
alias ls=\"ls -Altr --color=auto\" \n\
pushd /${APP} >/dev/null 2>&1 && git pull 2>/dev/null && popd >/dev/null 2>&1 || popd >/dev/null 2>&1\n\
"\
>> /home/$UNAME/.bashrc
