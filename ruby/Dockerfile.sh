FROM local/seed:ubuntu-18.04 as top

##  . ./setenv && build -t ubuntu-18.04 --arg=gituser=${CUSER} --arg=SSH_PRIVATE_KEY=${KEYNAME} --key SSH_PRIVATE_KEY_STREAM ${KEYPATH}

##  run --rm -I
##  run --rm -I --env=dev --user=root -w /root -v=${PWD}/ruby:/root/ruby.assets local/u18-ruby
##  run -u ${GITUSER} --env=dev -I -v=${sandbox}/ruby:/home/${GITUSER}/ruby.assets --rm local/ruby
##  CUSER=${GITUSER} CPATH=/home/${CUSER} run -u $CUSER --env=dev --rm -I -v=${PWD}/ruby:${CPATH}/ruby.assets -p=3000:3000 local/ruby


FROM top as git
RUN apt-get -qq update \
&& apt-get -qq install \
git \
&& apt-get clean

RUN apt-get -qq install \
sudo


FROM git as user
ARG gituser=$gituser
RUN useradd -ms /bin/bash -U $gituser \
&& echo "ALL ALL=(ALL) NOPASSWD: ALL"\
>>/etc/sudoers


FROM user as security
ARG THISUSER=$gituser
ARG HOMEPATH=/home

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
&& sed -i 's/\/Users\/***REMOVED***/'$SAFEHOME'/' $GIT_CONFIG \
&& chmod 600 $SSH_PRIVATE_KEY_PATH/$SSH_PRIVATE_KEY \
&& chown -R $THISUSER:$THISUSER $USERHOME

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

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 \
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

#RUN DEBIAN_FRONTEND=noninteractive apt-get -qq install \
#postgresql postgresql-contrib libpq-dev \
#&& cp -p /var/lib/postgresql/10/main/postgresql.auto.conf /var/lib/postgresql/10/main/postgresql.conf \
#&& echo 'export postgre_data_directory=/var/lib/postgresql/10/main' >>/etc/bash.bashrc
#ENV postgre_data_directory='/var/lib/postgresql/10/main'

#/usr/lib/postgresql/10/bin/postgres
#/etc/postgresql/10/main/postgresql.conf
#su - postgres

FROM sqlite as bashrc

RUN echo '### NODE ###\n\
grey "Updating nvm: " && echo $(cd .nvm && git pull)\n\
if  ! command -v nvm >/dev/null; then\n\
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm\n\
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion\n\
fi\n\
#echo $PATH\n\
function nodever() {\n\
  if [ ! -z $1 ]; then\n\
    nvm install ${1} >/dev/null 2>&1 && nvm use ${_} > /dev/null 2>&1\\\n\
      && nvm alias default ${_} > /dev/null 2>&1; blue "Node:"; node -v; else\n\
    grey "Use nodever to install or switch node versions:" && echo && echo " usage: nodever [ver]"; blue "Node:"; node -v && blue "nvm:"; nvm -v; fi;\n\
}\n\
nodever\n\
'\
>>$USERHOME/.bashrc

RUN echo '### YARN (NEEDS NVM) ###\n\
  if ! command -v yarn >/dev/null 2>&1; then grey "Getting yarn: " && npm install --global yarn >/dev/null; fi\n\
'\
>>$USERHOME/.bashrc


RUN echo '### RUBY RAILS ###\n\
function rubyver {\n\
  local RUBY_VER=$1 && local RAILS=$2\n\
  if [[ ! $RAILS == default ]]; then RAILS_VER="-v $RAILS";fi\n\
  if [ ! -z $1 ]; then\n\
    if [[ ! ${RUBY_VER} == $(rvm current) ]]; then\n\
      grey "Getting ruby:" && echo -n "${RUBY_VER} " && grey "rails:" && echo ${RAILS}\n\
      rvm install ${RUBY_VER} && rvm --default use ${RUBY_VER} && gem install rails ${RAILS_VER}\n\
    fi\n\
  fi\n\
  blue "Ruby:"; echo $(rvm current)\n\
  blue "Gem:"; gem -v\n\
  blue "Rails:"; rails -v\n\
}\n\
\
rubyver 2.7 default\n\
grey "Ruby versions with:" && echo rvm list known\n\
grey "install ruby with:" && echo rvm install ruby-[RUBY_VER] \&\& rvm --default use ruby-[RUBY_VER]\n\
grey "install rails with:" && echo gem install rails -v [RAILS_VER]\n\
blue "YARN:"; yarn -v\n\
blue "SQLite3:"; sqlite3 --version\n\
\n\
'\
>>$USERHOME/.bashrc

#RUN echo '### SET PERMISSIONS ###\n\
#chown '$THISUSER':'$THISUSER' '$USERHOME'/*\n\
#'\
#>>$USERHOME/.bashrc

ENV DOCKER_ENV=ruby
RUN echo '### SHARED HISTORY ###\n\
if [ -d ${HOME}/public.assets/bash_history/ ]; then export HISTFILE="${HOME}/public.assets/bash_history/history.${DOCKER_ENV}"; fi && green "Shared bash history at:" && echo ${HISTFILE}\n\
'\
>>$USERHOME/.bashrc

RUN echo '\n\
export PS1="\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]$ "\n\
alias ls="ls -Altr --color=auto"\n\
'\
>>$USERHOME/.bashrc


WORKDIR $USERHOME
EXPOSE 3000

FROM bashrc as vimvc
ARG line="set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab autoindent"
ARG line="$line\nset number"
ARG line="$line\nset nocompatible"
ARG line="$line\nsyntax on"
ARG line="$line\ncolo pablo"
ARG line="$line\nset cursorline"
ARG line="$line\nhi CursorLine   cterm=NONE ctermbg=237 ctermfg=NONE"
ARG line="$line\nhi CursorLineNr   cterm=NONE ctermbg=36 ctermfg=NONE"
RUN echo "$line" >$USERHOME/.vimrc
