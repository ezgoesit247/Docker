FROM local/seed:ubuntu-18.04 as top
RUN apt-get -qq update
### DOCKER ###
RUN apt-get install -qq \
apt-transport-https \
ca-certificates \
gnupg-agent \
software-properties-common \
&& curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
&& apt-key fingerprint 0EBFCD88 \
&& add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
&& apt-get -qq update \
&& apt-get install -qq \
docker-ce \
docker-ce-cli \
containerd.io

### DOCKER COMPOSE ###
RUN curl -sL https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose\
&& chmod +x /usr/local/bin/docker-compose



#ARG app=node
#ARG localuser
#ARG U=$localuser
#ARG UDIR=/home
#ARG UDIRPATH=$UDIR/$U

#RUN apt-get -qq install sudo \
#&& useradd -ms /bin/bash -d $UDIRPATH -U $U \
#&& echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

#VOLUME /$app

#FROM top

#USER $U
#WORKDIR $UDIRPATH
#ENV DOCKER_ENV=$app
#ENV DOCKER_ENV=$DOCKER_ENV


#RUN echo '### DOCKER ###\n\
#if ! service docker status; then service docker start; fi && sleep 2 && service docker status\n\
#cyan "Docker:"; docker --version\n\
#if docker run --rm hello-world 2> /dev/null | grep -o "Hello from Docker!"\n\
#then pass "Docker Hello World"\n\
#else fail "Docker Hello World"\n\
#fi\n\
#cyan "Docker Compose:"; docker-compose --version\n\
#'\
#>>/etc/bash.bashrc

#RUN sudo apt-get -qq update \
#   && sudo apt-get install build-essential dkms

#https://www.vagrantup.com/docs/providers/virtualbox/boxes
#apt-get install linux-headers-$(uname -r) build-essential dkms
RUN apt-get -qq clean
