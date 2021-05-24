#!/bin/bash
FROM local/seed:ubuntu-20.04 as top
RUN apt-get -qq install \
sudo \
&& echo "ALL ALL=(ALL) NOPASSWD: ALL"\
>>/etc/sudoers

FROM top as user
VOLUME userhome
ARG gituser=ropedope

RUN mkdir /userhome

RUN groupadd -g 1000 ropedope \
&& useradd -d /userhome/ropedope -s /bin/bash -m ropedope -u 1000 -g 1000
