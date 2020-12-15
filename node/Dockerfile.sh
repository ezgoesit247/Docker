FROM ubuntu:18.04
CMD ["/bin/bash"]

RUN apt-get -y -qq update && apt-get -y -qq upgrade \
  && apt-get -y -qq install \
    sudo
RUN echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
  && useradd -rm -s /bin/bash -d /home/poweruser -U -G sudo -u 1001 poweruser
USER poweruser
WORKDIR /home/poweruser
ENV DOCKER_ENV=node
RUN   echo 'clear\n \
if [ -d _assets/bash_history/ ]; then export HISTFILE="${HOME}/_assets/bash_history/history.${DOCKER_ENV}" && echo "Shared bash history at: ${HISTFILE}"; else echo "bash history not persisted: ${HISTFILE}"; fi\n \
export HISTTIMEFORMAT="%F	%T	"' >> /home/poweruser/.bashrc

### GEN EDS- yarrgh ###
RUN sudo apt-get -y -qq install \
   curl \
   wget \
   gnupg2 \
   unzip \
   vim \
   iputils-ping
RUN echo "12 4" | sudo apt-get -y -qq install software-properties-common
RUN sudo apt-get -y -qq install \
   apt-transport-https \
   ca-certificates \
   gnupg-agent \
   python \
   git \
   python3-pip
RUN   sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
RUN   sudo ln -s /usr/bin/pip3 /usr/bin/pip
RUN   echo '\n \
### FUNCTIONS ###\n \
   grep "DISTRIB_DESCRIPTION" /etc/lsb-release\n \
   function showcolors { for bg in `seq 0 9`; do for fg in `seq 0 9`; do echo -n "`expr $fg` `expr $bg`: " && color `expr $fg` `expr $bg` "Tyler & Corey"; echo; done; done }\n \
   alias colors=showcolors\n \
   function color  { echo -n "$(tput setaf $1;tput setab $2)${3}$(tput sgr 0) "; }\n \
   function green  { color 4 2 "${*}"; }\n \
   function yellow { color 0 3 "${*}"; }\n \
   function red    { color 9 1 "${*}"; }\n \
   function blue   { color 6 4 "${*}"; }\n \
   function cyan   { color 9 6 "${*}"; }\n \
   function grey   { color 0 7 "${*}"; }\n \
   function pass   { echo; echo "$(green PASS: ${*})"; echo; }\n \
   function warn   { echo; echo "$(yellow PASS: ${*})"; echo; }\n \
   function fail   { echo; echo "$(red FAIL: ${*})"; echo; }\n \
   function info   { echo; echo "$(grey INFO: ${*})"; echo; }\n \
   blue "python:"; python --version\n \
   blue "pip: "; pip --version' >> /home/poweruser/.bashrc



### JAVA & DEV ###
RUN sudo apt-get -y -qq install \
   openjdk-8-jdk \
   maven \
   mysql-client
RUN   echo '### DEVTOOLS ###\n \
   export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64\n \
   export M2_HOME=/usr/share/maven\n \
   if command -v java > /dev/null 2>&1; then blue "java:"; java -version; else yellow "No Java"; fi;\n \
   if command -v javac > /dev/null 2>&1; then blue "javac:"; javac -version; else yellow "No JDK"; fi;\n \
   if command -v mvn > /dev/null 2>&1; then blue "maven"; mvn --version; else yellow "No Maven"; fi;\n \
   if command -v mysql > /dev/null 2>&1; then blue "mysql client:"; mysql --version; else yellow "No MySql Cient"; fi;\n \
   if [ -d /apache-activemq-5.16.0 ];\n \
      then green "$(/apache-activemq-5.16.0/bin/activemq start)"; echo;\n \
      else grey "apache-activemq not mounted, not installed"; echo;\n \
   fi;' >> /home/poweruser/.bashrc

### NODE ###
RUN sudo apt-get -y -qq update && sudo apt-get -y -qq upgrade \
   && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
   && echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list \
   && sudo apt-get -y install \
      yarn \
   && git clone https://github.com/nvm-sh/nvm.git /home/poweruser/.nvm
RUN   echo '### NODE ###\n \
   if  ! command -v nvm > /dev/null; then\n \
   . /home/poweruser/.nvm/nvm.sh\n \
   export NVM_DIR="$HOME/.nvm"\n \
   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm\n \
   [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion\n \
   fi\n \
   function nodever() { if [ ! -z $1 ]; then nvm install ${1} > /dev/null 2>&1 && nvm use ${_} > /dev/null 2>&1 && nvm alias default ${_} > /dev/null 2>&1; blue "Node:"; node -v; else echo usage: nodedef ver; fi; }\n \
   if command -v nvm > /dev/null  && ! command -v node; then blue "nvm:";nvm install --lts\n \
   else blue "Node:"; node -v \n \
   fi' >> /home/poweruser/.bashrc
