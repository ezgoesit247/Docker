#!/bin/bash
FROM local/jdk8header as part1


RUN apt-get install -qq sudo \
&& echo "ALL ALL=(ALL) NOPASSWD: ALL" \
>>/etc/sudoers

FROM part1 as part2
ENV HADOOP_VERSION=2.10.1
ENV HADOOP_HOME=/hadoop
COPY assets/software/hadoop-${HADOOP_VERSION}.tar.gz hadoop-${HADOOP_VERSION}.tar.gz
RUN sudo tar -zxf hadoop-${HADOOP_VERSION}.tar.gz \
   && sudo mv hadoop-${HADOOP_VERSION} $HADOOP_HOME \
   && sudo rm -rf hadoop-${HADOOP_VERSION}.tar.gz

USER root
ARG USER=poweruser
RUN groupadd -g 1000 $USER
RUN useradd -d /home/$USER -s /bin/bash -m $USER -u 1000 -g 1000
#RUN echo 'export JAVA_HOME=/usr/share/jdk1.8 \
#   && export M2_HOME=/usr/share/maven \
#   && export HADOOP_HOME=/hadoop \
#   && export PATH="$PATH:$JAVA_HOME/bin:${HADOOP_HOME}/bin:${M2_HOME}/bin"' >> /etc/bash.bashrc
FROM part2 as part3
RUN addgroup hadoop_ \
   && useradd -rm -s /bin/bash -d /home/hduser_ -U -G sudo -G hadoop_ -u 1002 hduser_
RUN chown -R hduser_:hadoop_ /hadoop

ENV PATH="$PATH:${HADOOP_HOME}/bin"

RUN mkdir /app && sudo mkdir /app/hadoop && sudo mkdir /app/hadoop/tmp
RUN chown -R hduser_:hadoop_ /app
RUN chmod 750 -R /app

USER poweruser

RUN echo 'if command -v hadoop > /dev/null 2>&1; then blue "Hadoop:"; hadoop version; fi;\n'  >> /home/poweruser/.bashrc

ENV DOCKER_ENV=hadoop
