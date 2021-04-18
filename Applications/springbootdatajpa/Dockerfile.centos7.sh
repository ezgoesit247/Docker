FROM local/centos7-appdev as top

##  . setenv

##  run --env=dev --purpose=database --app=${APP} mysql/mysql-server:5.7

##  build --arg=APP=${APP} --arg=gituser=${CUSER} --arg=SSH_PRIVATE_KEY=${KEYNAME} --key SSH_PRIVATE_KEY_STREAM ${KEYPATH} -f Dockerfile.${OS}.sh Applications/${APP}

##  run --rm --env=dev --purpose=sandbox --container=${APP} --app=${APP} -v=${APP}:/${APP} local/${APP}:centos8

ENV GIT_SSH=/root/bin/git-ssh
ARG ROOT_SAFE_PATH=\\/root
ARG GIT_CONFIG=/root/.gitconfig
ARG KNOWN_HOSTS=/root/.ssh/known_hosts
ARG GIT_IGNORE_GLOBAL=/root/.gitignore_global
COPY assets.docker/git-ssh $GIT_SSH
COPY assets.docker/.gitconfig $GIT_CONFIG
COPY assets.docker/known_hosts $KNOWN_HOSTS
COPY assets.docker/.gitignore_global $GIT_IGNORE_GLOBAL

ARG SSH_PRIVATE_KEY_PATH=/root/.ssh
ARG SSH_PRIVATE_KEY
ARG SSH_PRIVATE_KEY_STREAM
RUN echo "${SSH_PRIVATE_KEY_STREAM}" > $SSH_PRIVATE_KEY_PATH/$SSH_PRIVATE_KEY

RUN chmod 700 /root/.ssh \
&& chmod 755 /root/bin \
&& chmod 755 $GIT_SSH \
&& chmod 600 $KNOWN_HOSTS \
&& chmod 644 $GIT_CONFIG \
&& chmod 644 $GIT_IGNORE_GLOBAL \
&& sed -i 's/\/Users\/***REMOVED***/'$ROOT_SAFE_PATH'/' $GIT_CONFIG \
&& chmod 600 $SSH_PRIVATE_KEY_PATH/$SSH_PRIVATE_KEY

ARG UNAME=default_virtual
ARG UDIR=/home
ARG UDIRPATH=$UDIR/$UNAME
ARG UDIR_SAFE_PATH=\\/home\\/$UNAME

RUN useradd -ms /bin/bash -d $UDIRPATH -U $UNAME \
&& echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
&& mkdir $UDIRPATH/bin

FROM top as code

ARG gituser
ARG APP
VOLUME /$APP
RUN git clone git@github.com:$gituser/$APP /$APP \
&& chown -R $UNAME:$UNAME /$APP /$APP/.git \
&& rm -rf $GIT_CONFIG /root/.ssh /root/bin

FROM code as oktapre
#RUN sudo yum install -y \
#flatpak \
#&& sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo \
#&& flatpak install -y flathub com.okta.developer.CLI \
#&& echo -e "\
#alias okta=\"flatpak run com.okta.developer.CLI\" \
#"\
#>> /home/$UNAME/.bashrc


FROM oktapre as okta
#ENV OKTADOMAIN=https://dev-8737669.okta.com
#ENV OKTAPSSWD='P@ssw0rd!'
#ENV OKTATOKEN='00s638kkGbqmX8Ojaqa6RDs8GcAMF9C4KdhvIrcEJ8'
#RUN echo -e '\
#echo OKTADOMAIN: $OKTADOMAIN \
#&& echo OKTAPSSWD: $OKTAPSSWD \
#&& echo OKTATOKEN: $OKTATOKEN \
#&& export JAVA_HOME=/usr/local/jdk11 && export PATH=$JAVA_HOME/bin:$PATH \
#'\
#>> /home/$UNAME/.bashrc

FROM okta as setup2

#RUN sudo yum install -y dnf
#RUN sudo dnf install -y httpie

FROM setup2 as httpie
RUN sudo yum install -y python3 \
&& sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
&& sudo python -m pip install --upgrade pip setuptools \
&& sudo python -m pip install --upgrade httpie


FROM httpie
ENV GIT_SSH=$UDIRPATH/bin/git-ssh
ARG GIT_CONFIG=$UDIRPATH/.gitconfig
ARG KNOWN_HOSTS=$UDIRPATH/.ssh/known_hosts
ARG GIT_IGNORE_GLOBAL=$UDIRPATH/.gitignore_global

COPY assets.docker/git-ssh $GIT_SSH
COPY assets.docker/.gitconfig $GIT_CONFIG
COPY assets.docker/known_hosts $KNOWN_HOSTS
COPY assets.docker/.gitignore_global $GIT_IGNORE_GLOBAL

RUN chmod 755 $UDIRPATH/bin \
&& chmod 755 $GIT_SSH \
&& chmod 600 $KNOWN_HOSTS \
&& chmod 644 $GIT_CONFIG \
&& chmod 644 $GIT_IGNORE_GLOBAL \
&& sed -i 's/\/Users\/***REMOVED***/'$UDIR_SAFE_PATH'/' $GIT_CONFIG \
&& chown -R $UNAME:$UNAME $UDIR/*

USER $UNAME
WORKDIR $UDIRPATH
ARG DOCKER_ENV=$APP
ENV DOCKER_ENV=$DOCKER_ENV
ENV PS1="\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]\$ "
ENV HISTTIMEFORMAT="%F	%T	"

RUN echo -e "\n\
export JAVA_HOME=/usr/local/jdk11 && export PATH=\$JAVA_HOME/bin:\$PATH \n\
if command -v git > /dev/null 2>&1; then git version; else echo \"No Git\"; echo; fi;\n\
if command -v java > /dev/null 2>&1; then java -version; else echo \"No Java\"; echo; fi;\n\
if command -v javac > /dev/null 2>&1; then javac -version; else echo \"No JDK\"; echo; fi;\n\
if command -v mvn > /dev/null 2>&1; then mvn --version; else echo \"No Maven\"; echo; fi;\n\
if command -v mysql > /dev/null 2>&1; then mysql --version; else echo \"No MySql Cient\"; echo; fi;\n\
"\
>>/home/$UNAME/.bashrc

RUN sudo ln -fsn /$APP ${UDIRPATH}/$APP \
&& sudo chown -R $UNAME:$UNAME $UDIRPATH \
&& echo -e "\
alias ls=\"ls -Altr --color=auto\" \n\
pushd /${APP} >/dev/null 2>&1 && git pull 2>/dev/null && popd >/dev/null 2>&1 || popd >/dev/null 2>&1\n\
"\
>>/home/$UNAME/.bashrc
