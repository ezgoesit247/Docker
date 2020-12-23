FROM local/u18-seed

###  JAVA & DEV ###
COPY assets/jdk-8u271-linux-x64.tar.gz jdk-8u271-linux-x64.tar.gz
RUN sudo tar -zxf jdk-8u271-linux-x64.tar.gz \
   && sudo mv jdk1.8.0_271 /usr/share/jdk1.8 \
   && sudo rm -rf jdk-8u271-linux-x64.tar.gz

COPY assets/apache-maven-3.6.3-bin.tar.gz apache-maven-3.6.3-bin.tar.gz
RUN sudo tar -zxf apache-maven-3.6.3-bin.tar.gz \
   && sudo mv apache-maven-3.6.3 /usr/share/maven \
   && sudo rm -rf apache-maven-3.6.3-bin.tar.gz

#ENV JAVA_HOME=/usr/share/jdk1.8
#ENV M2_HOME=/usr/share/maven/
#ENV PATH="$PATH:$JAVA_HOME/bin:${M2_HOME}/bin"

RUN sudo apt-get -qq update \
   && sudo apt-get -qq install \
   mysql-client
RUN   echo '### DEVTOOLS ###\n \
   if command -v java > /dev/null 2>&1; then blue "java:"; java -version; else yellow "No Java"; fi;\n \
   if command -v javac > /dev/null 2>&1; then blue "javac:"; javac -version; else yellow "No JDK"; fi;\n \
   if command -v mvn > /dev/null 2>&1; then blue "maven"; mvn --version; else yellow "No Maven"; fi;\n \
   if command -v mysql > /dev/null 2>&1; then blue "mysql client:"; mysql --version; else yellow "No MySql Cient"; fi;\n \
   if [ -d /apache-activemq-5.16.0 ];\n \
      then green "$(/apache-activemq-5.16.0/bin/activemq start)"; echo;\n \
      else grey "apache-activemq not mounted, not installed"; echo;\n \
   fi;' >> /home/poweruser/.bashrc

### NODE ###
RUN sudo apt-get install -qq gnupg2 \
   && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
   && echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list \
   && sudo apt-get install -qq \
      yarn \
   && git clone https://github.com/nvm-sh/nvm.git /home/poweruser/.nvm
RUN   echo '### NODE ###\n \
   pushd /home/poweruser/.nvm\n \
   git pull\n \
   popd\n \
   if  ! command -v nvm > /dev/null; then\n \
   . /home/poweruser/.nvm/nvm.sh\n \
   export NVM_DIR="$HOME/.nvm"\n \
   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm\n \
   [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion\n \
   fi\n \
   function nodever() { if [ ! -z $1 ]; then nvm install ${1} > /dev/null 2>&1 && nvm use ${_} > /dev/null 2>&1 && nvm alias default ${_} > /dev/null 2>&1; blue "Node:"; node -v; else echo -e " usage: nodedef ver\n\tinstall or switch node versions, currently:"; blue "Node:"; node -v; fi; }\n \
   if command -v nvm > /dev/null  && ! command -v node; then blue "nvm:";nvm install --lts; fi\n \
   blue "Node:"; node -v \n \
   ' >> /home/poweruser/.bashrc

COPY assets/hadoop-2.10.1.tar.gz hadoop-2.10.1.tar.gz
RUN sudo tar -zxf hadoop-2.10.1.tar.gz \
   && sudo mv hadoop-2.10.1 /hadoop \
   && sudo rm -rf hadoop-2.10.1.tar.gz

USER root
#RUN echo 'export JAVA_HOME=/usr/share/jdk1.8 \
#   && export M2_HOME=/usr/share/maven \
#   && export HADOOP_HOME=/hadoop \
#   && export PATH="$PATH:$JAVA_HOME/bin:${HADOOP_HOME}/bin:${M2_HOME}/bin"' >> /etc/bash.bashrc
RUN addgroup hadoop_ \
   && useradd -rm -s /bin/bash -d /home/hduser_ -U -G sudo -G hadoop_ -u 1002 hduser_
RUN chown -R hduser_:hadoop_ /hadoop

ENV JAVA_HOME=/usr/share/jdk1.8
ENV M2_HOME=/usr/share/maven/
ENV HADOOP_HOME=/hadoop
ENV PATH="$PATH:$JAVA_HOME/bin:${HADOOP_HOME}/bin:${M2_HOME}/bin"

RUN mkdir /app && sudo mkdir /app/hadoop && sudo mkdir /app/hadoop/tmp
RUN chown -R hduser_:hadoop_ /app
RUN chmod 750 -R /app

USER poweruser




ENV DOCKER_ENV=developer
