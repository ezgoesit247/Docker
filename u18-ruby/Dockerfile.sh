FROM local/u18-seed as top

##  . ./setenv && build --arg=gituser=${CUSER} --arg=SSH_PRIVATE_KEY=${KEYNAME} --key SSH_PRIVATE_KEY_STREAM ${KEYPATH}

##  run --rm -I
##  run --rm -I --env=dev --user=root -w /root -v=${PWD}/ruby:/root/ruby.assets local/u18-ruby


FROM top as git
RUN apt-get -qq update \
&& apt-get -qq install \
git \
&& apt-get clean

FROM git as rvminstall
#RUN apt-get -qq update \
#&& apt-get -qq install \
#ruby-full \
#&& apt-get clean

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 \
7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
&& curl -sSL https://get.rvm.io | bash -s stable --ruby \
&& echo 'source /usr/local/rvm/scripts/rvm' >>/etc/bash.bashrc


FROM rvminstall as rvmconfig
RUN /usr/local/rvm/bin/rvm get stable --autolibs=enable \
&& usermod -a -G rvm root


FROM rvmconfig as gemupdate
RUN /usr/local/rvm/bin/rvm \
&& echo "gem: --no-document" >> ~/.gemrc \
&& PATH="/usr/local/rvm/rubies/default/bin:$PATH" /usr/local/rvm/rubies/default/bin/gem update --system


FROM gemupdate as rails
RUN /usr/local/rvm/rubies/default/bin/gem install rails

FROM rails as postgresql
#RUN DEBIAN_FRONTEND=noninteractive apt-get -qq install \
#postgresql postgresql-contrib libpq-dev \
#&& cp -p /var/lib/postgresql/10/main/postgresql.auto.conf /var/lib/postgresql/10/main/postgresql.conf \
#&& echo 'export postgre_data_directory=/var/lib/postgresql/10/main' >>/etc/bash.bashrc
#ENV postgre_data_directory='/var/lib/postgresql/10/main'

#/usr/lib/postgresql/10/bin/postgres
#/etc/postgresql/10/main/postgresql.conf
#su - postgres


FROM postgresql as last



FROM last as user
ARG gituser=$gituser
ARG THISUSER=root
ARG USERHOME=/root
#ARG UDIR_SAFE_PATH=\\/home\\/$gituser
#RUN apt-get -qq install \
#sudo \
#&& useradd -ms /bin/bash -d $USERHOME -U $gituser \
#&& echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


ENV GIT_SSH=$USERHOME/bin/git-ssh
ARG ROOT_SAFE_PATH=\\/root
ARG GIT_CONFIG=$USERHOME/.gitconfig
ARG KNOWN_HOSTS=$USERHOME/.ssh/known_hosts
ARG GIT_IGNORE_GLOBAL=$USERHOME/.gitignore_global
COPY assets.docker/git-ssh $GIT_SSH
COPY assets.docker/.gitconfig $GIT_CONFIG
COPY assets.docker/known_hosts $KNOWN_HOSTS
COPY assets.docker/.gitignore_global $GIT_IGNORE_GLOBAL

ARG SSH_PRIVATE_KEY_PATH=$USERHOME/.ssh
ARG SSH_PRIVATE_KEY
ARG SSH_PRIVATE_KEY_STREAM
RUN echo "${SSH_PRIVATE_KEY_STREAM}" > $SSH_PRIVATE_KEY_PATH/$SSH_PRIVATE_KEY

RUN chmod 700 $USERHOME/.ssh \
&& chmod 755 $USERHOME/bin \
&& chmod 755 $GIT_SSH \
&& chmod 600 $KNOWN_HOSTS \
&& chmod 644 $GIT_CONFIG \
&& chmod 644 $GIT_IGNORE_GLOBAL \
&& sed -i 's/\/Users\/***REMOVED***/'$ROOT_SAFE_PATH'/' $GIT_CONFIG \
&& chmod 600 $SSH_PRIVATE_KEY_PATH/$SSH_PRIVATE_KEY \
&& chown -R $THISUSER:$THISUSER $USERHOME


#USER $gituser
#WORKDIR $USERHOME


FROM user as nodeinstall
RUN git clone https://github.com/nvm-sh/nvm.git ~/.nvm

FROM nodeinstall as nodeinstall0
### NVM *must have* NVM_DIR
ENV NVM_DIR=$USERHOME/.nvm
ENV NVM_HOME=$NVM_DIR
RUN echo $([ -s $NVM_DIR/nvm.sh ] && . $NVM_DIR/nvm.sh && [ -s $NVM_DIR/bash_completion ] && . $NVM_DIR/bash_completion && nvm install --lts)

FROM nodeinstall0 as bashrc
RUN echo '### NODE ###\n\
pushd ~/.nvm\n\
git pull\n\
popd\n\
if  ! command -v nvm >/dev/null; then\n\
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm\n\
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion\n\
fi\n\
function nodever() {\n\
  if [ ! -z $1 ]; then\n\
    nvm install ${1} >/dev/null 2>&1 && nvm use ${_} > /dev/null 2>&1\\\n\
      && nvm alias default ${_} > /dev/null 2>&1; blue "Node:"; node -v; else\n\
    grey "Use nodever to install or switch node versions:" && echo && echo " usage: nodever [ver]"; blue "Node:"; node -v && blue "nvm:"; nvm -v; fi;\n\
}\n\
nodever\n\
'\
>>$USERHOME/.bashrc

RUN echo '### RVM ###\n\
grey "ruby versions with:" && echo rvm list known\n\
#X=3 && Y=0\n\
#echo X=$X Y=$Y\n\
grey "install ruby with:" && echo rvm install ruby-\$X.\$Y \&\& rvm --default use ruby-\$X.\$Y\n\
blue "Gem:"; gem -v\n\
blue "Ruby:"; ruby -v\n\
'\
>>$USERHOME/.bashrc

RUN echo '### RAILS ###\n\
blue "Rails:"; rails -v\n\
'\
>>$USERHOME/.bashrc

RUN echo '### SET PERMISSIONS ###\n\
chown '$THISUSER':'$THISUSER' '$USERHOME'/*\n\
'\
>>$USERHOME/.bashrc

RUN echo '### SHARED HISTORY ###\n\
if [ -d ${HOME}/public.assets/bash_history/ ]; then export HISTFILE="${HOME}/public.assets/bash_history/history.${DOCKER_ENV}"; fi && green "Shared bash history at:" && echo ${HISTFILE}\n\
'\
>>$USERHOME/.bashrc

WORKDIR $USERHOME
