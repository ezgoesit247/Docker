FROM ubuntu:18.04
CMD ["/bin/bash"]

RUN apt-get -qq update && apt-get -qq upgrade \
  && apt-get -qq install \
    sudo

RUN echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
  && useradd -rm -s /bin/bash -d /home/poweruser -U -G sudo -u 1001 poweruser

USER poweruser
WORKDIR /home/poweruser
ENV DOCKER_ENV=default
RUN   echo 'clear\n \
if [ -d _assets/bash_history/ ]; then export HISTFILE="${HOME}/_assets/bash_history/history.${DOCKER_ENV}" && echo "Shared bash history at: ${HISTFILE}"; else echo "bash history not persisted: ${HISTFILE}"; fi\n \
export HISTTIMEFORMAT="%F	%T	"' >> /home/poweruser/.bashrc

RUN sudo apt-get -qq install \
   curl \
   wget \
   gnupg2 \
   unzip \
   vim \
   iputils-ping
RUN echo "12 4" | sudo apt-get -y install software-properties-common
RUN sudo apt-get -y install \
   apt-transport-https \
   ca-certificates \
   gnupg-agent \
   python \
   git \
   python3-pip

ENV DEBIAN_FRONTEND=noninteractive
RUN sudo ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
   && sudo apt-get install -y tzdata \
   && sudo dpkg-reconfigure --frontend noninteractive tzdata

RUN   echo 'clear\n \
### FUNCTIONS ###\n \
   grep "DISTRIB_DESCRIPTION" /etc/lsb-release\n' >> /home/poweruser/.bashrc
