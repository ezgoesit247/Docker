FROM local/u18-docker as top

RUN apt-get -qq update \
&& apt-get install -qq \
git


FROM top as jdk11
COPY assets.docker/jdk-11.tar.gz jdk-11.tar.gz
ARG JAVA11=/usr/local/jdk11
ENV JAVA_HOME=$JAVA11
ENV PATH="$PATH:$JAVA_HOME/bin"
RUN tar zxf jdk-11.tar.gz -C /tmp \
&& mv /tmp/jdk* ${JAVA11} \
&& rm -rf jdk-11.tar.gz


FROM jdk11 as go
ARG GO_TAR=go1.tar.gz
ARG GO_HOME=/usr/local/go
ENV GO_HOME=$GO_HOME
ENV PATH="$PATH:$GO_HOME/bin"

COPY assets.docker/$GO_TAR $GO_TAR
RUN tar zxf $GO_TAR -C /tmp \
&& mv /tmp/go* ${GO_HOME} \
&& rm -rf $GO_TAR

FROM go as sudo
RUN apt-get -qq install \
sudo \
&& echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


FROM sudo as userstuff
RUN echo "export GOPATH=\$(go env GOPATH)\n\
function use { if [ -d /usr/local/\${1} ]; then export JAVA_HOME=/usr/local/\${1} && export PATH=\${JAVA_HOME}/bin:\${PATH}; fi; echo JAVA_HOME is \${JAVA_HOME}; }\n\
"\
>>/etc/bash.bashrc
