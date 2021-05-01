FROM local/centos-centos8 as top

RUN yum update -y \
&& yum install -y \
git \
mysql \
&& yum clean all \
&& echo -e "\n\
if command -v git > /dev/null 2>&1; then git version; else echo \"No Git\"; echo; fi\n\
if command -v mysql > /dev/null 2>&1; then mysql --version; else echo \"No MySql Cient\"; echo; fi\n\
"\
>>/etc/bashrc

FROM top as top2
RUN yum install -y  \
sudo \
&& yum clean all



FROM top2 as go
ARG GO_TAR=go1.tar.gz
ARG GO_HOME=/usr/local/go
ENV GO_HOME=$GO_HOME
ENV PATH="$PATH:$GO_HOME/bin"

COPY assets.docker/$GO_TAR $GO_TAR
RUN tar zxf $GO_TAR -C /tmp \
&& mv /tmp/go* ${GO_HOME} \
&& rm -rf $GO_TAR

FROM go as top5
RUN yum install -y python3 python2 && python3 -m pip --version \
&& python3 -m pip install --upgrade pip setuptools && python3 -m pip install --upgrade httpie \
&& http --version

FROM top5 as last
RUN echo -e "\n\
export GOPATH=\$(go env GOPATH)\n\
mkdir -p \$GOPATH\
"\
>>/etc/bashrc
