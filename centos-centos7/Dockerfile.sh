FROM centos:7 as tmp1

COPY assets.docker/jdk-8.tar.gz jdk-8.tar.gz
ARG JAVA8=/usr/local/jdk1.8
RUN tar zxf jdk-8.tar.gz -C /tmp \
&& mv /tmp/jdk* ${JAVA8} \
&& rm -rf jdk-8.tar.gz

FROM tmp1 as tmp2
COPY assets.docker/apache-maven-3.tar.gz apache-maven-3.tar.gz
ARG M2_HOME=/usr/local/maven
RUN tar zxf apache-maven-3.tar.gz -C /tmp \
&& mv /tmp/apache-maven-3* ${M2_HOME} \
&& rm -rf apache-maven-3.tar.gz

FROM tmp2 as tmp3

ENV JAVA_HOME=$JAVA8
ENV M2_HOME=$M2_HOME
ENV PATH="$PATH:$JAVA_HOME/bin:$M2_HOME/bin"
ENV PS1="\[\033[1;32m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]\$ "

RUN echo -e "\
alias ls=\"ls -Altr --color=auto\" \n\
grep PRETTY_NAME /etc/os-release|sed \"s/[\\\"=_PRETTYNAME]//g\" \n\
"\
>> /etc/bashrc
# sudo su - -c "echo 'grep PRETTY_NAME /etc/os-release|sed \"s/[\\\"=_PRETTYNAME]//g\"' >>/etc/bashrc"