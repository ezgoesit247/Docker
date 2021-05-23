#!/bin/bash
FROM ubuntu:20.04 as t1

RUN apt-get update
RUN apt-get install -y firefox

FROM t1
ARG USER=foxyroxy
RUN groupadd -g 1000 $USER
RUN useradd -d /home/$USER -s /bin/bash -m $USER -u 1000 -g 1000
USER $USER
ENV HOME /home/$USER
CMD /usr/bin/firefox
