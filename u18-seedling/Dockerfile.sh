FROM ubuntu:18.04
CMD ["/bin/bash"]

RUN apt-get -qq update \
   && apt-get -qq install \
      sudo \
      curl \
      wget \
      unzip \
      vim

RUN echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers   && useradd -rm -s /bin/bash -d /home/poweruser -U -G sudo -u 1001 poweruser

RUN   echo 'export HISTTIMEFORMAT="%F	%T	"\n'\
>> /etc/bash.bashrc
ARG DOCKER_ENV=default
RUN   echo 'if [ -d ${HOME}/_assets/bash_history/ ]; then export HISTFILE="${HOME}/_assets/bash_history/history.'$DOCKER_ENV'"; fi'\
>> /etc/bash.bashrc


RUN   echo 'alias ls="ls -Altr --color=auto"\n\
export PS1="${debian_chroot:+($debian_chroot)}\[\033[1;32m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]\$ " \n'\
>> /root/.bashrc


RUN sudo apt-get -qq clean
