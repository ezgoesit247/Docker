FROM local/u18-seedling as intermediate

### GEN EDS- yarrgh ###
RUN apt-get -qq update \
   && apt-get -qq install -y \
   gnupg2 \
   iputils-ping \
   software-properties-common \
   apt-transport-https \
   ca-certificates \
   gnupg-agent \
   python \
   python3-pip
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
   && ln -s /usr/bin/pip3 /usr/bin/pip


RUN apt-get -qq clean
