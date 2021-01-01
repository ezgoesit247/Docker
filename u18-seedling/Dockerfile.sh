FROM ubuntu:18.04
CMD ["/bin/bash"]

RUN apt-get -y -qq update \
   && apt-get -qq install \
      sudo
RUN echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers   && useradd -rm -s /bin/bash -d /home/poweruser -U -G sudo -u 1001 poweruser
RUN   echo 'export PS1="\[\033[1;32m\]\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\w\[\033[0m\]\$ " \n\
if [ -d _assets/bash_history/ ]; then export HISTFILE="${HOME}/_assets/bash_history/history.${DOCKER_ENV}" && echo "Shared bash history at: ${HISTFILE}"; else echo "bash history not persisted, check the -v mapping: ${HISTFILE}"; fi\n \
export HISTTIMEFORMAT="%F	%T	"\n \
alias ls="ls -Altr --color=auto"\n' >> /root/.bashrc
USER poweruser
WORKDIR /home/poweruser
RUN   echo 'export PS1="\[\033[1;34m\]\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\w\[\033[0m\]\$ " \n' >> /home/poweruser/.bashrc

ENV DOCKER_ENV=default
RUN   echo 'if [ -d _assets/bash_history/ ]; then export HISTFILE="${HOME}/_assets/bash_history/history.${DOCKER_ENV}" && echo "Shared bash history at: ${HISTFILE}"; else echo "bash history not persisted: ${HISTFILE}"; fi\n \
export HISTTIMEFORMAT="%F	%T	"\n \
alias ls="ls -Altr --color=auto"\n' >> /home/poweruser/.bashrc

RUN sudo apt-get clean
