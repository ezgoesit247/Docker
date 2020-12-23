FROM ubuntu:18.04
CMD ["/bin/bash"]

RUN apt-get -y -qq update && apt-get -y -qq upgrade   && apt-get -y -qq install     sudo
RUN echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers   && useradd -rm -s /bin/bash -d /home/poweruser -U -G sudo -u 1001 poweruser
RUN alias ls="ls -ltrA --color=auto"
USER poweruser
RUN alias ls="ls -ltrA --color=auto"
WORKDIR /home/poweruser
ENV DOCKER_ENV=default
RUN   echo '\
if [ -d _assets/bash_history/ ]; then export HISTFILE="${HOME}/_assets/bash_history/history.${DOCKER_ENV}" && echo "Shared bash history at: ${HISTFILE}"; else echo "bash history not persisted: ${HISTFILE}"; fi\n \
export HISTTIMEFORMAT="%F	%T	"' >> /home/poweruser/.bashrc
