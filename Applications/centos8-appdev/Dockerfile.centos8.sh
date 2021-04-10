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

FROM top2 as end
RUN echo -e "\n\
if command -v git > /dev/null 2>&1; then git version; else echo \"No Git\"; echo; fi;\n\
if command -v java > /dev/null 2>&1; then java -version; else echo \"No Java\"; echo; fi;\n\
if command -v javac > /dev/null 2>&1; then javac -version; else echo \"No JDK\"; echo; fi;\n\
if command -v mvn > /dev/null 2>&1; then mvn --version; else echo \"No Maven\"; echo; fi;\n\
if command -v mysql > /dev/null 2>&1; then mysql --version; else echo \"No MySql Cient\"; echo; fi;\n\
"\
>>/etc/bashrc
