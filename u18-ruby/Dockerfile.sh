FROM local/u18-seed as top

##  . ./setenv && build --arg=gituser=${CUSER} --arg=SSH_PRIVATE_KEY=${KEYNAME} --key SSH_PRIVATE_KEY_STREAM ${KEYPATH}

##  run --rm -I --env=dev --user=root local/u18-ruby

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


FROM rvmconfig as nodeinstall
RUN git clone https://github.com/nvm-sh/nvm.git ~/.nvm


FROM nodeinstall as gemupdate
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

FROM last as bashrc
RUN echo '### NODE ###\n\
pushd ~/.nvm\n\
git pull\n\
popd\n\
if  ! command -v nvm >/dev/null; then\n\
. ~/.nvm/nvm.sh\n\
export NVM_DIR="$HOME/.nvm"\n\
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm\n\
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion\n\
fi\n\
function nodever() { if [ ! -z $1 ]; then nvm install ${1} >/dev/null 2>&1 && nvm use ${_} > /dev/null 2>&1 && nvm alias default ${_} > /dev/null 2>&1; blue "Node:"; node -v; else echo -e " usage: nodedef ver\n\tinstall or switch node versions, currently:"; blue "Node:"; node -v; fi; }\n\
if command -v nvm >/dev/null  && ! command -v node; then blue "nvm:";nvm install --lts; fi\n\
blue "Node:"; node -v \n\
'\
>>/etc/bash.bashrc

RUN echo '### RVM ###\n\
rvm list known\n\
X=3 && Y=0\n\
echo X=$X Y=$Y\n\
echo install ruby: rvm install ruby-\$X.\$Y \&\& rvm --default use ruby-\$X.\$Y\n\
blue "Gem:"; gem -v\n\
blue "Ruby:"; ruby -v\n\
'\
>>/etc/bash.bashrc

RUN echo '### RAILS ###\n\
blue "Rails:"; rails -v\n\
'\
>>/etc/bash.bashrc
