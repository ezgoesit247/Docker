FROM local/seed:ubuntu-20.04 as top

##  DOCKER_ENV=ruby && TAG1=ubuntu-20.04 && TAG2=ubuntu && RUBY_VER=ruby-2.7.3 && RAILS_VER=latest && . ./setenv && DEFAULT_RUBY_VER=${RUBY_VER} && DEFAULT_RAILS_VER=${RAILS_VER} && DEBUG=0 build --arg=DEFAULT_RAILS_VER=${DEFAULT_RAILS_VER} --arg=DEFAULT_RUBY_VER=${DEFAULT_RUBY_VER} --arg=LOCALHOMESAFE=${LOCALHOMESAFE} --arg=gituser=${CUSER} --arg=SSH_PRIVATE_KEY=${KEYNAME} --key SSH_PRIVATE_KEY_STREAM ${KEYPATH} --arg=DOCKER_ENV=${DOCKER_ENV} -t ${TAG1} -t=${TAG2}

##  run --rm -I

##  run --rm -I --env=dev --user=root -w /root --rm local/ruby

##  TAG="ubuntu-20.04" && if [ ${TAG} ]; then TAG=":${TAG}"; fi && run -u ${CUSER} --env=dev --app=${APP} -I -p=3000:3000 --name=${CNAME} local/ruby${TAG}


FROM top as git
RUN apt-get -qq update \
&& apt-get -qq install \
git \
&& apt-get clean

RUN apt-get -qq install \
sudo


FROM git as user
ARG gituser=$gituser
RUN groupadd -g 1000 $gituser \
&& useradd -d /home/$gituser -s /bin/bash -m $gituser -u 1000 -g 1000 \
&& echo "ALL ALL=(ALL) NOPASSWD: ALL"\
>>/etc/sudoers


FROM user as security
ARG THISUSER=$gituser
ARG HOMEPATH=/home
ARG LOCALHOMESAFE=$LOCALHOMESAFE

# THESE SHOULD NOT *need* TO CHANGE
ARG SAFEPATH=\\$HOMEPATH
ARG USERHOME=$HOMEPATH/$THISUSER
ARG SAFEHOME=$SAFEPATH\\/$THISUSER
ENV GIT_SSH=$USERHOME/bin/git-ssh
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
ENV GITLOGIN=$THISUSER@gmail.com
ENV HEROKULOGIN=$GITLOGIN
RUN chown $THISUSER:$THISUSER $GITTOKEN \
&& chown $THISUSER:$THISUSER $HEROKUTOKEN \
&& chmod 600 $GITTOKEN \
&& chmod 600 $HEROKUTOKEN \
&& chmod 600 $HEROKUPASSWD


#echo 'export GITTOKEN=$(cat $GITTOKEN)' >>$USERHOME/.bashrc
USER $THISUSER

FROM security as nodeinstall
RUN git clone https://github.com/nvm-sh/nvm.git ~/.nvm

FROM nodeinstall as nodeinstall0
### NVM *must have* NVM_DIR
ENV NVM_DIR=$USERHOME/.nvm
ENV NVM_HOME=$NVM_DIR
RUN echo $([ -s $NVM_DIR/nvm.sh ] && . $NVM_DIR/nvm.sh && [ -s $NVM_DIR/bash_completion ] && . $NVM_DIR/bash_completion && nvm install --lts)


FROM nodeinstall0 as rvminstall
#RUN apt-get -qq update \
#&& apt-get -qq install \
#ruby-full \
#&& apt-get clean

RUN sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 \
7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
&& curl -sSL https://get.rvm.io | sudo bash -s stable --ruby \
&& echo 'source /usr/local/rvm/scripts/rvm\n\
'\
>>$USERHOME/.bashrc \
&& echo 'rvm_silence_path_mismatch_check_flag=1\n\
'\
>>$USERHOME/.rvmrc

FROM rvminstall as rvmconfig
RUN /usr/local/rvm/bin/rvm get stable --autolibs=enable \
& sudo usermod -a -G rvm $THISUSER


FROM rvmconfig as rvmgemupdate
RUN /usr/local/rvm/bin/rvm \
&& echo "gem: --no-document" >> ~/.gemrc \
&& PATH="/usr/local/rvm/rubies/default/bin:$PATH" /usr/local/rvm/rubies/default/bin/gem update --system


FROM rvmgemupdate as rvmruby
RUN /usr/local/rvm/bin/rvm install ruby

FROM rvmruby as rvmrails
RUN /usr/local/rvm/rubies/default/bin/gem install rails

FROM rvmrails as sqlite
RUN sudo apt-get -qq install \
sqlite3 \
&& sudo apt-get clean

FROM sqlite as tzdata
RUN sudo ln -fs /usr/share/zoneinfo/CST6CDT /etc/localtime \
&& sudo DEBIAN_FRONTEND=noninteractive \
apt-get install -y --no-install-recommends \
tzdata

#RUN DEBIAN_FRONTEND=noninteractive apt-get -qq install \
#postgresql postgresql-contrib libpq-dev \
#&& cp -p /var/lib/postgresql/10/main/postgresql.auto.conf /var/lib/postgresql/10/main/postgresql.conf \
#&& echo 'export postgre_data_directory=/var/lib/postgresql/10/main' >>/etc/bash.bashrc
#ENV postgre_data_directory='/var/lib/postgresql/10/main'

#/usr/lib/postgresql/10/bin/postgres
#/etc/postgresql/10/main/postgresql.conf
#su - postgres

FROM tzdata as bashrc
ARG DEFAULT_RUBY_VER=$DEFAULT_RUBY_VER
ARG DEFAULT_RAILS_VER=$DEFAULT_RAILS_VER

run echo ${DEFAULT_RUBY_VER} \
&& echo ${DEFAULT_RUBY_VER}

RUN echo '### NODE ###\n\
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

RUN echo '### YARN (NEEDS NVM) ###\n\
  if ! command -v yarn >/dev/null 2>&1; then grey "Getting yarn: " && npm install --global yarn >/dev/null; fi\n\
'\
>>$USERHOME/.bashrc


RUN echo '### RUBY RAILS ###\n\
export DEFAULT_RUBY_VER='$DEFAULT_RUBY_VER'\n\
export DEFAULT_RAILS_VER='$DEFAULT_RAILS_VER'\n\
function rubyver() {\n\
  if [ $# -eq 0 ]; then\n\
    yellow "Use rubyver to switch ruby & rails:" && echo -e "\\n usage: rubyver ruby-[X.Y.Z] [RAILSVER($DEFAULT_RAILS_VER)]"\n\
#    return ${LINENO}\n\
  fi\n\
  local RUBY_VER=${1} && local RAILS_VER=${2}\n\
  if [ ! -z ${1} ]; then\n\
    if [[ ! ${RUBY_VER} == $(rvm current) ]]; then\n\
      cyan "getting ruby:" && echo -n "${RUBY_VER} " && rvm install ${RUBY_VER} 2>/dev/null\\\n\
        && rvm --default use ${RUBY_VER}\n\
    fi\n\
  fi\n\
  if [[ ! ${RAILS_VER} == ${DEFAULT_RAILS_VER} ]];then RAILS="-v ${RAILS_VER}";fi\n\
  cyan "getting rails:" && echo ${RAILS_VER} && gem install rails ${RAILS} 2>/dev/null\n\
  cyan "getting bundler" && gem install bundler\n\
  blue "Ruby:"; echo $(rvm current)\n\
  blue "Gem:"; gem -v\n\
  blue "Rails:"; rails -v\n\
  blue "Bundler:"; bundler -v\n\
  blue "YARN:"; yarn -v\n\
  blue "SQLite3:"; sqlite3 --version\n\
}\n\
\
rubyver \
  $(if [[ ! ${RUBY_VERSION} == ${DEFAULT_RUBY_VER} ]];then echo ${DEFAULT_RUBY_VER} ${DEFAULT_RAILS_VER};fi; exit)\n\
#export HEROKUHOME=/usr/local/heroku/bin\n\
#if [ ! -d $HEROKUHOME ] && [ -d ~/.nvm ]\n\
#  then cyan "Getting heroku" && echo\n\
#    source <(curl -sL https://cdn.learnenough.com/heroku_install) 2>/dev/null\n\
#  else if ! command -v heroku;then export PATH=$PATH:$HEROKUHOME;fi\n\
#fi\n\
#blue "Heroku:"; heroku --version\n\
#grey "Ruby versions with:" && echo rvm list known\n\
#grey "install ruby with:" && echo rvm install ruby-[RUBY_VER] \&\& rvm --default use ruby-[RUBY_VER]\n\
#grey "install rails with:" && echo gem install rails -v [RAILS_VER]\n\
\n\
'\
>>$USERHOME/.bashrc

#RUN echo '### SET PERMISSIONS ###\n\
#chown '$THISUSER':'$THISUSER' '$USERHOME'/*\n\
#'\
#>>$USERHOME/.bashrc
ARG DOCKER_ENV
ENV DOCKER_ENV=$DOCKER_ENV
RUN echo '### SHARED HISTORY ###\n\
if [ -d ${HOME}/public.assets/bash_history/ ]; then export HISTFILE="${HOME}/public.assets/bash_history/history.${DOCKER_ENV}"; fi && green "Shared bash history at:" && echo ${HISTFILE}\n\
'\
>>$USERHOME/.bashrc

RUN echo '\n\
export PS1="\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]$ "\n\
alias ls="ls -Altr --color=auto"\n\
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
EXPOSE 3000
RUN mkdir $USERHOME/code-store \
&& mkdir $USERHOME/scratch

VOLUME $USERHOME/code-store
VOLUME $USERHOME/scratch


FROM bashrc as awscliinstall
VOLUME $USERHOME/aws
RUN mkdir $USERHOME/aws
RUN echo '\n\
if ! command -v aws; then sudo '$USERHOME'/aws/install; fi\n\
' \
>>$USERHOME/.bashrc


#AWS CLI
#RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
#  && unzip awscliv2.zip #&& rm -rf awscliv2.zip \
#  && sudo mv aws/ /usr/local/ && sudo /usr/local/aws/install
