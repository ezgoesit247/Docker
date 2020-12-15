FROM ubuntu:18.04
CMD ["/bin/bash"]

RUN apt-get -y -qq update && apt-get -y -qq upgrade \
 && echo "12 4" | apt-get -y -qq install software-properties-common \
 && apt-get -y -qq install \
    apt-transport-https \
    ca-certificates \
    gnupg-agent \
    python3 \
    python3-pip \
    gnupg2 \
    unzip \
    iputils-ping \
    ansible \
      curl \
      gnupg \
      unzip \
      vim \
      mysql-client \
      iputils-ping \
      wget \
      git

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -
RUN add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
 && echo waiting... && sleep 3
RUN apt-get -y -qq update
RUN apt-get -y -qq upgrade
RUN apt-get -y -qq --allow-unauthenticated install \
    docker-ce \
    docker-ce-cli \
    containerd.io

RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6A030B21BA07F4FB \
# && echo waiting... && sleep 3

RUN apt-get -y -qq update && apt-get -y -qq upgrade \
 && apt-get -y -qq install \
    kubectl \
    kubelet \
    kubeadm \
    kubernetes-cni

 RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3|bash \
 && helm repo add stable https://charts.helm.sh/stable \
 && curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
 && if ! command -v aws > /dev/null; then echo "Installing AWS CLI..." && unzip -q awscliv2.zip && ./aws/install; fi \
 && echo 'function showcolors { for bg in `seq 0 9`; do for fg in `seq 0 9`; do echo -n "`expr $fg` `expr $bg`: " && color `expr $fg` `expr $bg` "Tyler & Corey"; echo; done; done }'  >> /root/.bashrc   && echo 'alias colors=showcolors' >> /root/.bashrc   && echo 'function color  { echo -n "$(tput setaf $1;tput setab $2)${3}$(tput sgr 0) "; }' >> /root/.bashrc   && echo 'function green  { color 4 2 "${*}"; }' >> /root/.bashrc   && echo 'function yellow { color 0 3 "${*}"; }' >> /root/.bashrc   && echo 'function red    { color 0 1 "${*}"; }' >> /root/.bashrc   && echo 'function blue   { color 6 4 "${*}"; }' >> /root/.bashrc   && echo 'function cyan   { color 4 6 "${*}"; }' >> /root/.bashrc   && echo 'function grey   { color 0 7 "${*}"; }' >> /root/.bashrc   && echo 'function pass   { echo; echo "$(green PASS: ${*})"; echo; }' >> /root/.bashrc   && echo 'function warn   { echo; echo "$(yellow PASS: ${*})"; echo; }' >> /root/.bashrc   && echo 'function fail   { echo; echo "$(red FAIL: ${*})"; echo; }' >> /root/.bashrc   && echo 'function info   { echo; echo "$(grey INFO: ${*})"; echo; }' >> /root/.bashrc

