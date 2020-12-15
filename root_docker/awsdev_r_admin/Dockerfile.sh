FROM ubuntu_seed_admin:20.04

RUN apt-get -y update && apt-get -y upgrade \
  && apt-get -y install \
    openjdk-8-jdk \
    maven

#AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install

##AWS KUBE CTL
RUN curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.8/2020-09-18/bin/linux/amd64/kubectl \
&& chmod 744 ./kubectl && mv ./kubectl /usr/local/bin

#AWS EKS CTL
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/0.31.0/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /usr/local/bin/ \
&& chmod 744 /usr/local/bin/eksctl

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
