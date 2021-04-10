FROM local/centos-centos8 as top

RUN yum update -y \
&& yum install -y \
git \
mysql \
&& yum clean all

FROM top as top2

RUN yum install -y  \
sudo \
&& yum clean all
