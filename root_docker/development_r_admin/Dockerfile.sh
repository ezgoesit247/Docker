FROM ubuntu_seed_admin:20.04

RUN apt-get -y update && apt-get -y upgrade \
  && apt-get -y install \
    sudo \
    openjdk-8-jdk \
    maven

#AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install

COPY assets/* /root/

RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> /root/.bashrc \
  && echo 'export M2_HOME=/usr/share/maven' >> /root/.bashrc \
  && echo 'blue "java:"; java -version' >> /root/.bashrc \
  && echo 'blue "javac:"; javac -version' >> /root/.bashrc \
  && echo 'blue "maven:"; mvn --version' >> /root/.bashrc \
  && echo 'cyan "kubectl:"; kubectl version --short --client' >> /root/.bashrc \
  && echo 'cyan "eksctl:"; eksctl version' >> /root/.bashrc \
  && echo 'cyan "AWS_CLI:"; /usr/local/bin/aws --version' >> /root/.bashrc \
  && echo 'if [ -d /apache-activemq-5.16.0 ]; \
    then green "$(/apache-activemq-5.16.0/bin/activemq start)"; echo; \
  else grey "apache-activemq not mounted, not installed"; echo; \
    fi' >> /root/.bashrc
