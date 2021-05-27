#!/bin/bash
##  TAG1=ubuntu-20.04 && TAG2=ubuntu && build -t ${TAG1} -t=${TAG2}

FROM local/seed:ubuntu-20.04 as top

RUN apt-get -qq update \
&& apt-get install -qq \
git

FROM top as jdk8
ARG JDK8_TAR=jdk-1.8.tar.gz
ARG JAVA8=/usr/local/jdk1.8
ENV JAVA_HOME=$JAVA8
ENV PATH="$PATH:$JAVA_HOME/bin"
COPY assets.docker/$JDK8_TAR $JDK8_TAR
RUN tar zxf $JDK8_TAR -C /tmp \
&& mv /tmp/jdk* ${JAVA8} \
&& rm -rf $JDK8_TAR


FROM jdk8 as jdk11
ARG JDK11_TAR=jdk-11.tar.gz
ARG JAVA11=/usr/local/jdk11
ENV JAVA_HOME=$JAVA11
#ENV PATH="$PATH:$JAVA_HOME/bin"
COPY assets.docker/$JDK11_TAR $JDK11_TAR
RUN tar zxf $JDK11_TAR -C /tmp \
&& mv /tmp/jdk* ${JAVA11} \
&& rm -rf $JDK11_TAR


FROM jdk11 as go
#ARG GO_TAR=go1.tar.gz
#ARG GO_HOME=/usr/local/go
#ENV GO_HOME=$GO_HOME
#ENV PATH="$PATH:$GO_HOME/bin"
#COPY assets.docker/$GO_TAR $GO_TAR
#RUN tar zxf $GO_TAR -C /tmp \
#&& mv /tmp/go* ${GO_HOME} \
#&& rm -rf $GO_TAR

FROM go as sudo
RUN apt-get -qq install \
sudo \
&& echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

FROM sudo as maven
ARG M2_TAR=apache-maven-3.tar.gz
ARG M2_HOME=/usr/local/maven
ENV M2_HOME=$M2_HOME
ENV PATH="$PATH:$M2_HOME/bin"
COPY assets.docker/$M2_TAR $M2_TAR
RUN tar zxf $M2_TAR -C /tmp \
&& mv /tmp/apache-maven-3* ${M2_HOME} \
&& rm -rf $M2_TAR


FROM maven as userstuff
#RUN echo "export GOPATH=\$(go env GOPATH)\n\
#function use { if [ -d /usr/local/\${1} ]; then export JAVA_HOME=/usr/local/\${1} && export PATH=\${JAVA_HOME}/bin:\${PATH}; fi; echo JAVA_HOME is \${JAVA_HOME}; }\n\
#"\
#>>/etc/bash.bashrc

RUN apt-get clean
