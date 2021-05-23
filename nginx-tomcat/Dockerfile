#!/bin/bash
FROM nginx AS tmp

COPY assets.docker/jdk-1.8.tar.gz jdk-1.8.tar.gz
COPY assets.docker/apache-maven-3.tar.gz apache-maven-3.tar.gz
COPY assets.docker/apache-tomcat-8.5.tar.gz apache-tomcat-8.tar.gz

FROM tmp as tmp1

ARG JAVA_HOME=/jdk1.8
ARG M2_HOME=/maven
ARG TOMCAT_HOME=/tomcat

RUN tar zxf jdk-1.8.tar.gz -C /tmp \
&& mv /tmp/jdk* ${JAVA_HOME} \
&& rm -rf jdk-8.tar.gz

RUN tar zxf apache-maven-3.tar.gz -C /tmp \
&& mv /tmp/apache-maven-3* ${M2_HOME} \
&& rm -rf apache-maven-3.tar.gz

RUN tar zxf apache-tomcat-8.tar.gz -C /tmp \
&& mv /tmp/apache-tomcat* ${TOMCAT_HOME} \
&& rm -rf apache-tomcat-8.tar.gz

ENV JAVA_HOME=$JAVA_HOME
ENV M2_HOME=$M2_HOME
ENV TOMCAT_HOME=$TOMCAT_HOME



FROM tmp1 as tmp2
RUN apt-get -qq update




FROM tmp2 as tmp3

RUN chown -R root:root ${JAVA_HOME} \
&& chown -R root:root ${M2_HOME} \
&& chown -R root:root ${TOMCAT_HOME}

ENV PATH="$PATH:$JAVA_HOME/bin:$M2_HOME/bin"


RUN echo "\
export PS1=\"\[\033[1;32m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]\$ \";\
function color  { echo -n \"$(tput setaf $1;tput setab $2)${3}$(tput sgr 0) \"; };\
function green  { color 4 2 \"${*}\"; };\
function yellow { color 0 3 \"${*}\"; };\
function red    { color 9 1 \"${*}\"; };\
function blue   { color 6 4 \"${*}\"; };\
function cyan   { color 9 6 \"${*}\"; };\
function grey   { color 0 7 \"${*}\"; };\
function pass   { echo; echo \"$(green PASS: ${*})\"; echo; };\
function warn   { echo; echo \"$(yellow PASS: ${*})\"; echo; };\
function fail   { echo; echo \"$(red FAIL: ${*})\"; echo; };\
function info   { echo; echo \"$(grey INFO: ${*})\"; echo; };\
blue python:; python --version;\
blue pip:; pip --version;\
if command -v java  > /dev/null 2>&1; then blue java:; java -version; else yellow No Java; echo; fi;\
if command -v javac > /dev/null 2>&1; then blue javac:; javac -version; else yellow No JDK; echo; fi;\
if command -v mvn   > /dev/null 2>&1; then blue maven; mvn --version; else yellow No Maven; echo; fi;\
if command -v mysql > /dev/null 2>&1; then blue mysql client:; mysql --version; else yellow No MySql Cient; echo; fi;\
alias ls='ls -Altr --color=auto'\
"\
>> /root/.bashrc


FROM tmp3 as tmp4
COPY assets.docker/10-listen-on-ipv6-by-default.sh /docker-entrypoint.d/
COPY assets.docker/15-start-tomcat.sh /docker-entrypoint.d/
RUN chmod u+x docker-entrypoint.d/*
