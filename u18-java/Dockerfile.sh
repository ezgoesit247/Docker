FROM local/u18-seed

RUN sudo apt-get -qq purge openjdk-\*
ARG JAVA_HOME=/jdk1.8
ARG M2_HOME=/maven

ENV JAVA_HOME=$JAVA_HOME
ENV M2_HOME=$M2_HOME
###  JAVA & DEV ###
COPY assets.docker/jdk-8u271-linux-x64.tar.gz jdk-8u271-linux-x64.tar.gz
RUN sudo tar -zxf jdk-8u271-linux-x64.tar.gz \
   && sudo mv jdk1.8.0_271 $JAVA_HOME \
   && sudo rm -rf jdk-8u271-linux-x64.tar.gz

COPY assets.docker/apache-maven-3.6.3-bin.tar.gz apache-maven-3.6.3-bin.tar.gz
RUN sudo tar -zxf apache-maven-3.6.3-bin.tar.gz \
   && sudo mv apache-maven-3.6.3 $M2_HOME \
   && sudo rm -rf apache-maven-3.6.3-bin.tar.gz



RUN echo 'export PATH=${PATH}:${JAVA_HOME}/bin:${M2_HOME}/bin' >> ~/.bashrc

RUN sudo apt-get -qq update \
   && sudo apt-get -qq install \
   mysql-client
RUN   echo '### DEVTOOLS ###\n \
   if command -v java > /dev/null 2>&1; then blue "java:"; java -version; else yellow "No Java"; echo; fi;\n \
   if command -v javac > /dev/null 2>&1; then blue "javac:"; javac -version; else yellow "No JDK"; echo; fi;\n \
   if command -v mvn > /dev/null 2>&1; then blue "maven"; mvn --version; else yellow "No Maven"; echo; fi;\n \
   if command -v mysql > /dev/null 2>&1; then blue "mysql client:"; mysql --version; else yellow "No MySql Cient"; echo; fi;' \
>> /home/poweruser/.bashrc

RUN wget https://golang.org/dl/go1.15.6.linux-amd64.tar.gz \
  && sudo tar -C /usr/local -xzf go1.15.6.linux-amd64.tar.gz \
  && echo 'export PATH=$PATH:/usr/local/go/bin\n\
  if command -v go > /dev/null 2>&1; then blue "go:" && go version; else yellow "No Java"; echo; fi;' \
>> /home/poweruser/.bashrc

RUN   echo '\n \
if [ -d /apache-activemq-5.16.0 ];\n \
   then green "$(/apache-activemq-5.16.0/bin/activemq start)"; echo;\n \
   else grey "apache-activemq not mounted, not installed"; echo;\n \
fi;' \
>> /home/poweruser/.bashrc

ENV DOCKER_ENV=developer
RUN   echo 'if [ -d ${HOME}/_assets/bash_history/ ]; then export HISTFILE="${HOME}/_assets/bash_history/history.developer"; fi && green "Shared bash history at: " && echo ${HISTFILE}'\
>> /home/poweruser/.bashrc

RUN sudo apt-get -qq clean
