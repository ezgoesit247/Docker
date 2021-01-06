FROM local/u18-developer

RUN sudo apt-get -qq update
### DOCKER ###
RUN sudo apt-get install -qq \
      apt-transport-https \
      ca-certificates \
      gnupg-agent \
      software-properties-common \
   && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
   && sudo apt-key fingerprint 0EBFCD88 \
   && sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
   && sudo apt-get -qq update \
   && sudo apt-get install -qq \
      docker-ce \
      docker-ce-cli \
      containerd.io
RUN    echo '### DOCKER ###\n \
if ! sudo service docker status; then sudo service docker start; fi && sleep 2 && sudo service docker status\n \
cyan "Docker:"; docker --version\n \
if sudo docker run --rm hello-world 2> /dev/null | grep -o "Hello from Docker!"\n \
  then pass "Docker Hello World"\n \
  else fail "Docker Hello World"\n \
fi' >> /home/poweruser/.bashrc

### DOCKER COMPOSE ###
RUN sudo curl -sL https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose\
   && sudo chmod +x /usr/local/bin/docker-compose
RUN    echo '### DOCKER ###\n \
cyan "Docker Compose:"; docker-compose --version' >> /home/poweruser/.bashrc

#RUN sudo apt-get -qq update \
#   && sudo apt-get install build-essential dkms

#https://www.vagrantup.com/docs/providers/virtualbox/boxes
#apt-get install linux-headers-$(uname -r) build-essential dkms
ENV DOCKER_ENV=developer
