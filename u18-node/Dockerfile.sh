FROM local/u18-seed as top
### NODE ###
RUN apt-get install -qq gnupg2 \
&& curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
&& "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
&& apt-get install -qq \
yarn \
git

ARG GO_HOME=/usr/local/go
ARG GO_INSTALL_PATH=/usr/local
ENV GO_HOME=$GO_HOME
COPY assets.docker/go1.15.6.linux-amd64.tar.gz go.tar.gz
RUN tar -zxf go.tar.gz \
&& mv go $GO_INSTALL_PATH \
&& rm -rf go.tar.gz

ARG app=node
ARG localuser=poweruser
ARG U=$localuser
ARG UDIR=/home
ARG UDIRPATH=$UDIR/$U

RUN apt-get -qq install sudo \
&& useradd -ms /bin/bash -d $UDIRPATH -U $U \
&& echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

VOLUME /$app

#RUN chown -R $U:$U $app $app/.git


USER $U
WORKDIR $UDIRPATH
ENV DOCKER_ENV=$app
ENV DOCKER_ENV=$DOCKER_ENV

RUN git clone https://github.com/nvm-sh/nvm.git $UDIRPATH/.nvm

FROM top

ENV GO_HOME=$GO_HOME
ENV PATH="$PATH:$GO_HOME/bin"


RUN echo '### NODE ###\n\
pushd /home/poweruser/.nvm\n\
git pull\n\
popd\n\
if  ! command -v nvm > /dev/null; then\n\
. /home/poweruser/.nvm/nvm.sh\n\
export NVM_DIR="$HOME/.nvm"\n\
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm\n\
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion\n\
fi\n\
function nodever() { if [ ! -z $1 ]; then nvm install ${1} > /dev/null 2>&1 && nvm use ${_} > /dev/null 2>&1 && nvm alias default ${_} > /dev/null 2>&1; blue "Node:"; node -v; else echo -e " usage: nodedef ver\n\tinstall or switch node versions, currently:"; blue "Node:"; node -v; fi; }\n\
if command -v nvm > /dev/null  && ! command -v node; then blue "nvm:";nvm install --lts; fi\n\
blue "Node:"; node -v \n\
'\
>> ${UDIRPATH}/.bashrc



RUN echo '\n\
if command -v go > /dev/null 2>&1; then blue "Google Go:" && go version; else yellow "No Google Go"; echo; fi;\n\
'\
>> ${UDIRPATH}/.bashrc

RUN echo 'export PS1="${debian_chroot:+($debian_chroot)}\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]\$ " \n\
export HISTTIMEFORMAT="%F	%T	"\n\
if [ -d ${HOME}/public.assets/bash_history/ ]; then export HISTFILE="${HOME}/public.assets/bash_history/history.'$DOCKER_ENV'"; fi && green "Shared bash history at: " && echo ${HISTFILE}\n\
pushd /'$app' >/dev/null 2>&1 && git pull 2>/dev/null && popd >/dev/null 2>&1 || popd >/dev/null 2>&1\n\
'\
>> ${UDIRPATH}/.bashrc


RUN sudo apt-get -qq clean
