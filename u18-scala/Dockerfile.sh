FROM local/u18-seed

# RUN sudo apt-get -qq purge openjdk-\*
# ARG JAVA_HOME=/jdk1.8
ARG M2_HOME=/maven
ARG GO_HOME=/usr/local
# ENV JAVA_HOME=$JAVA_HOME
ENV M2_HOME=$M2_HOME
ENV GO_HOME=$GO_HOME
RUN curl -s https://mirrors.ocf.berkeley.edu/apache/maven/maven-3/3.6.3/source/apache-maven-3.6.3-src.tar.gz|sudo tar xz -C / \
  && sudo mv /apache-maven-3.6.3 $M2_HOME \
  && wget https://golang.org/dl/go1.15.6.linux-amd64.tar.gz \
  && sudo tar -C $GO_HOME -xzf go1.15.6.linux-amd64.tar.gz \
  && sudo apt-get -qq install scala

RUN echo 'export PATH=${PATH}:${JAVA_HOME}/bin:${M2_HOME}/bin:${GO_HOME}/bin' >> ~/.bashrc


RUN   echo '### DEVTOOLS ###\n \
   if command -v java > /dev/null 2>&1; then blue "java:"; java -version; else yellow "No Java"; echo; fi;\n \
   if command -v javac > /dev/null 2>&1; then blue "javac:"; javac -version; else yellow "No JDK"; echo; fi;\n \
   if command -v mvn > /dev/null 2>&1; then blue "maven"; mvn --version; else yellow "No Maven"; echo; fi;\n \
   if command -v mysql > /dev/null 2>&1; then blue "mysql client:"; mysql --version; else yellow "No MySql Cient"; echo; fi;\n \
   export PATH=$PATH:/usr/local/go/bin\n\
     if command -v go > /dev/null 2>&1; then blue "go:" && go version; else yellow "No Go"; echo; fi;' \
>> /home/poweruser/.bashrc




ENV DOCKER_ENV=developer
RUN   echo 'if [ -d ${HOME}/_assets/bash_history/ ]; then export HISTFILE="${HOME}/_assets/bash_history/history.developer"; fi && green "Shared bash history at: " && echo ${HISTFILE}'\
>> /home/poweruser/.bashrc

RUN sudo apt-get -qq clean
