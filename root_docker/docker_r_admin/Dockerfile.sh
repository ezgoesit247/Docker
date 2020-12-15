FROM development_admin

RUN apt-get -y update && apt-get -y upgrade \
  && apt-get -y install \
    ntp \
    ntpdate \
    ntpstat

#DOCKER + KUBERNETES
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
  && add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  && apt-get -y install \
    docker-ce \
    docker-ce-cli \
    containerd.io

RUN curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
  && chmod 744 /usr/local/bin/docker-compose

RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
    | tee /etc/apt/sources.list.d/kubernetes.list

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6A030B21BA07F4FB \
  && apt-get -y update && apt-get -y upgrade \
  && apt-get install -y \
    kubectl \
    kubelet \
    kubeadm \
    kubernetes-cni

RUN echo 'if ! service docker status; then service docker start; fi && sleep 2 && service docker status' >> /root/.bashrc \
  && echo 'cyan "Docker:"; docker --version' >> /root/.bashrc \
  && echo 'if docker run --rm hello-world 2> /dev/null | grep -o "Hello from Docker!"' >> /root/.bashrc \
  && echo '   then pass "Docker Hello World"' >> /root/.bashrc \
  && echo '   else fail "Docker Hello World"' >> /root/.bashrc \
  && echo 'fi' >> /root/.bashrc \
  && echo 'cyan "Docker Compose:"; docker-compose --version' >> /root/.bashrc \
  && echo 'if service ntp status > /dev/null; then service ntp stop; fi' >> /root/.bashrc \
  && echo 'service ntp stop && ntpdate time.nist.gov && service ntp start' >> /root/.bashrc \
  && echo 'echo "Doing NTP sync..."' >> /root/.bashrc \
  && echo 'ntp_tries=8 && ntp_delay_seconds=4 && i=0' >> /root/.bashrc \
  && echo 'while ! ntpstat > /dev/null 2>&1' >> /root/.bashrc \
  && echo '   do sleep ${ntp_delay_seconds} && i=`expr ${i} + 1`' >> /root/.bashrc \
  && echo '   if [ ${i} -ge ${ntp_tries} ]' >> /root/.bashrc \
  && echo '      then yellow "NTP:" && echo bailing && break' >> /root/.bashrc \
  && echo '   fi' >> /root/.bashrc \
  && echo 'done' >> /root/.bashrc \
  && echo 'if ntpstat > /dev/null 2>&1' >> /root/.bashrc \
  && echo '   then green "NTP:" && ntpstat' >> /root/.bashrc \
  && echo '   else red "NTP:" && echo "not synchronized"' >> /root/.bashrc \
  && echo 'fi' >> /root/.bashrc
