### BUILT WITH dosetup
FROM local/ubuntu-appdev:18.04 as root
ARG gituser
ARG CUSERHOME=/home/$gituser
RUN useradd -ms /bin/bash -d $CUSERHOME -U $gituser

ENV GIT_SSH=/root/bin/git-ssh
ARG ROOT_SAFE_PATH=\\/root
ARG GIT_CONFIG=/root/.gitconfig
ARG KNOWN_HOSTS=/root/.ssh/known_hosts
COPY assets.docker/git-ssh $GIT_SSH
COPY assets.docker/git-ssh $GIT_SSH
COPY assets.docker/.gitconfig $GIT_CONFIG
COPY assets.docker/known_hosts $KNOWN_HOSTS

ARG SSH_PRIVATE_KEY
ARG SSH_PRIVATE_KEY_STREAM
RUN echo "${SSH_PRIVATE_KEY_STREAM}" > /root/.ssh/$SSH_PRIVATE_KEY

RUN chmod 700 /root/.ssh && chmod 755 /root/bin && chmod 755 $GIT_SSH && chmod 600 $KNOWN_HOSTS && chmod 644 $GIT_CONFIG && sed -i 's/\/Users\/***REMOVED***/'$ROOT_SAFE_PATH'/' $GIT_CONFIG && chmod 600 /root/.ssh/$SSH_PRIVATE_KEY

VOLUME /mesen
RUN git clone git@github.com:$gituser/mesen /mesen && chown -R $gituser:$gituser /mesen /mesen/.git && ln -fsn /mesen $CUSERHOME/mesen
RUN apt-get -qq clean



FROM root as user
USER $gituser
WORKDIR $CUSERHOME
ENV GIT_SSH=$CUSERHOME/bin/git-ssh
ARG ROOT_SAFE_PATH=\\/home\\/$gituser
ARG GIT_CONFIG=$CUSERHOME/.gitconfig
ARG KNOWN_HOSTS=$CUSERHOME/.ssh/known_hosts
ARG GIT_IGNORE_GLOBAL=$CUSERHOME/.gitignore_global
COPY assets.docker/git-ssh $GIT_SSH
COPY assets.docker/.gitconfig $GIT_CONFIG
COPY assets.docker/known_hosts $KNOWN_HOSTS
COPY assets.docker/.gitignore_global $GIT_IGNORE_GLOBAL

ARG SSH_PRIVATE_KEY_PATH=$CUSERHOME/.ssh
ARG KEYSTREAM="echo \"${SSH_PRIVATE_KEY_STREAM}\" > $SSH_PRIVATE_KEY_PATH/$SSH_PRIVATE_KEY"
RUN sudo su - -c "$KEYSTREAM"

RUN sudo chown -R $gituser:$gituser $CUSERHOME && sudo chmod 700 $CUSERHOME/.ssh && sudo chmod 755 $CUSERHOME/bin && sudo chmod 755 $GIT_SSH && sudo chmod 600 $KNOWN_HOSTS && sudo chmod 644 $GIT_CONFIG && sudo chmod 644 $GIT_IGNORE_GLOBAL && sudo sed -i 's/\/Users\/***REMOVED***/'$ROOT_SAFE_PATH'/' $GIT_CONFIG && sudo chmod 600 $SSH_PRIVATE_KEY_PATH/$SSH_PRIVATE_KEY


RUN echo 'if ! sudo service docker status; then sudo service docker start; fi\nsudo docker run --rm hello-world 2> /dev/null | grep -o "Hello from Docker!"\n'>>$CUSERHOME/.bashrc

ARG DOCKER_ENV=mesen
ENV DOCKER_ENV=$DOCKER_ENV
RUN echo 'export PS1="\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]$ "\nexport HISTTIMEFORMAT="%F	%T	"\nalias ls="ls -Altr --color=auto"\nif [ -d ${HOME}/public.assets/bash_history/ ]; then export HISTFILE="${HOME}/public.assets/bash_history/history.${DOCKER_ENV}"; fi && green "Shared bash history at: " && echo ${HISTFILE}\npushd /${APP} >/dev/null 2>&1 && git pull 2>/dev/null && popd >/dev/null 2>&1 || popd >/dev/null 2>&1\n'>>$CUSERHOME/.bashrc

