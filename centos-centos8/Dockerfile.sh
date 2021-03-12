# docker build --rm -t local/centos-centos8 --build-arg=SSH_PRIVATE_KEY=${GITKEYNAME} --build-arg SSH_PRIVATE_KEY_STREAM="$(cat ~/.ssh/${GITKEYNAME})" .
# build --arg=SSH_PRIVATE_KEY=${GITKEYNAME} --key SSH_PRIVATE_KEY_STREAM ~/.ssh/${GITKEYNAME}
FROM centos:8 as tmp1
COPY assets.docker/jdk-8.tar.gz jdk-8.tar.gz
ARG JAVA_HOME=/usr/local/jdk1.8
RUN tar zxf jdk-8.tar.gz -C /tmp \
&& mv /tmp/jdk* ${JAVA_HOME} \
&& rm -rf jdk-8.tar.gz

FROM tmp1 as tmp2
COPY assets.docker/apache-maven-3.tar.gz apache-maven-3.tar.gz
ARG M2_HOME=/usr/local/maven
RUN tar zxf apache-maven-3.tar.gz -C /tmp \
&& mv /tmp/apache-maven-3* ${M2_HOME} \
&& rm -rf apache-maven-3.tar.gz

FROM tmp2 as tmp3
RUN yum update -y \
&& yum install -y git

FROM tmp3 as tmp4
ARG ROOT_SAFE_PATH=\\/root

ENV GIT_SSH=/root/bin/git-ssh
ARG GIT_CONFIG=/root/.gitconfig
ARG KNOWN_HOSTS=/root/.ssh/known_hosts

RUN mkdir /root/bin \
&& mkdir /root/.ssh

COPY assets.docker/git-ssh $GIT_SSH
COPY assets.docker/.gitconfig $GIT_CONFIG
COPY assets.docker/known_hosts $KNOWN_HOSTS

ARG SSH_PRIVATE_KEY_PATH=/root/.ssh
ARG SSH_PRIVATE_KEY
ARG SSH_PRIVATE_KEY_STREAM
RUN echo "${SSH_PRIVATE_KEY_STREAM}" > $SSH_PRIVATE_KEY_PATH/$SSH_PRIVATE_KEY

RUN chmod 700 /root/.ssh \
&& chmod 755 /root/bin \
&& chmod 755 $GIT_SSH \
&& chmod 600 $KNOWN_HOSTS \
&& chmod 644 $GIT_CONFIG \
&& sed -i 's/\/Users\/***REMOVED***/'$ROOT_SAFE_PATH'/' $GIT_CONFIG \
&& chmod 600 $SSH_PRIVATE_KEY_PATH/$SSH_PRIVATE_KEY \
&& echo "alias ls=\"ls -Altr --color=auto\"" \
>> /etc/bashrc

ENV JAVA_HOME=$JAVA_HOME
ENV M2_HOME=$M2_HOME
ENV PATH="$PATH:$JAVA_HOME/bin:$M2_HOME/bin"
ENV PS1="\[\033[1;32m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]\$ "

FROM tmp4 as tmp5
RUN yum clean all
