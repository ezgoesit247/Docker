FROM local/centos8-developer:systemd as developer1

# CUSER=${GITUSER} && KEYNAME=${GITKEYNAME} && KEYPATH=${GITKEYPATH}

# build --rm --arg=UNAME=${CUSER} --arg=gituser=${CUSER} --arg=SSH_PRIVATE_KEY=${KEYNAME} --key SSH_PRIVATE_KEY_STREAM ${KEYPATH} --usertag ${CUSER} -f Dockerfile.centos8.sh Applications/currencyexchange_py

# docker exec -it $(docker run --hostname centos8 -d --rm --privileged --name ${CUSER}-currencyexchange_py -v=docker_vol:/docker_vol -v=/sys/fs/cgroup:/sys/fs/cgroup:ro local/currencyexchange_py:${CUSER}) /bin/bash

FROM developer1 as final
ARG UNAME
ARG UPATH=/home/$UNAME
ARG UPATH_SAFE=\\/home\\/$UNAME
RUN useradd -ms /bin/bash -d $UPATH -U $UNAME \
&& usermod -a -G docker,users $UNAME \
&& echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
&& echo -e "\
alias ls=\"ls -Altr --color=auto\" \n\
export PS1=\"\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]\$ \" \n\
export HISTFILE=/docker_vol/history/$UNAME.bash_history \n\
cd /docker_vol \n\
"\
>>/$UPATH/.bashrc
