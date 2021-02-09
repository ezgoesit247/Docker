FROM local/u18-seed as intermediate

RUN apt-get -qq purge openjdk-\*
ARG JAVA_HOME=/usr/local/jdk1.8
ARG M2_HOME=/usr/local/maven

###  JAVA & DEV ###
COPY assets.docker/jdk-8u271-linux-x64.tar.gz jdk-8.tar.gz
RUN tar -zxf jdk-8.tar.gz \
&& mv jdk1.8.0_271 $JAVA_HOME \
&& rm -rf jdk-8.tar.gz

COPY assets.docker/apache-maven-3.6.3-bin.tar.gz apache-maven.tar.gz
RUN tar -zxf apache-maven.tar.gz \
&& mv apache-maven-3.6.3 $M2_HOME \
&& rm -rf apache-maven.tar.gz

ENV JAVA_HOME=$JAVA_HOME
ENV M2_HOME=$M2_HOME
ENV PATH="$PATH:$JAVA_HOME/bin:$M2_HOME/bin"
