FROM local/centos-centos7 as top

RUN yum update -y \
&& yum install -y \
git \
mysql \
&& yum clean all

FROM top as top2

RUN yum install -y  \
sudo \
&& yum clean all

FROM top2 as top3

COPY assets.docker/jdk-11.tar.gz jdk-11.tar.gz
ARG JAVA11=/usr/local/jdk11
RUN tar zxf jdk-11.tar.gz -C /tmp \
&& mv /tmp/jdk* ${JAVA11} \
&& rm -rf jdk-11.tar.gz
