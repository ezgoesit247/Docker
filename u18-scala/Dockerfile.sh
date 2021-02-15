FROM local/u18-seed as top

# RUN apt-get -qq purge openjdk-\*
# ARG JAVA_HOME=/jdk1.8
ARG M2_HOME=/maven
# ENV JAVA_HOME=$JAVA_HOME
ARG M2_HOME=/usr/local/maven

COPY assets.docker/apache-maven-3.6.3-bin.tar.gz apache-maven.tar.gz
RUN tar -zxf apache-maven.tar.gz \
&& mv apache-maven-3.6.3 $M2_HOME \
&& rm -rf apache-maven.tar.gz


ARG GO_HOME=/usr/local/go
ARG GO_INSTALL_PATH=/usr/local
COPY assets.docker/go1.15.6.linux-amd64.tar.gz go.tar.gz
RUN tar -zxf go.tar.gz \
&& mv go $GO_INSTALL_PATH \
&& rm -rf go.tar.gz

RUN apt-get -qq install \
scala

FROM top


ARG app=node
ARG localuser=poweruser
ARG U=$localuser
ARG UDIR=/home
ARG UDIRPATH=$UDIR/$U

RUN apt-get -qq install sudo \
&& useradd -ms /bin/bash -d $UDIRPATH -U $U \
&& echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


VOLUME /$app

#RUN chown -R $U:$U $app $app/.git


USER $U
WORKDIR $UDIRPATH
ENV DOCKER_ENV=$app
ENV DOCKER_ENV=$DOCKER_ENV

ENV M2_HOME=$M2_HOME
ENV GO_HOME=$GO_HOME
ENV PATH="$PATH:$GO_HOME/bin:$M2_HOME/bin"



RUN   echo '### DEVTOOLS ###\n \
if command -v java > /dev/null 2>&1; then blue "java:"; java -version; else yellow "No Java"; echo; fi;\n \
if command -v javac > /dev/null 2>&1; then blue "javac:"; javac -version; else yellow "No JDK"; echo; fi;\n \
if command -v mvn > /dev/null 2>&1; then blue "maven"; mvn --version; else yellow "No Maven"; echo; fi;\n \
if command -v mysql > /dev/null 2>&1; then blue "mysql client:"; mysql --version; else yellow "No MySql Cient"; echo; fi;\n \
export PATH=$PATH:/usr/local/go/bin\n\
 if command -v go > /dev/null 2>&1; then blue "go:" && go version; else yellow "No Go"; echo; fi;\
' \
>> ${UDIRPATH}/.bashrc




RUN echo 'export PS1="${debian_chroot:+($debian_chroot)}\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;31m\]\h:\[\033[0;37m\]\w\[\033[0m\]\$ " \n\
export HISTTIMEFORMAT="%F	%T	"\n\
if [ -d ${HOME}/public.assets/bash_history/ ]; then export HISTFILE="${HOME}/public.assets/bash_history/history.'$DOCKER_ENV'"; fi && green "Shared bash history at: " && echo ${HISTFILE}\n\
pushd /'$app' >/dev/null 2>&1 && git pull 2>/dev/null && popd >/dev/null 2>&1 || popd >/dev/null 2>&1\n\
'\
>> ${UDIRPATH}/.bashrc


RUN sudo apt-get -qq clean
