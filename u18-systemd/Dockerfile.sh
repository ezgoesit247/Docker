FROM local/u18-seed as top
ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/# deb/deb/g' /etc/apt/sources.list

RUN apt-get -qq update \
    && apt-get -qq install systemd systemd-sysv \
    && apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

 RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
 systemd-tmpfiles-setup.service ] || rm -f $i; done); \
 rm -f /lib/systemd/system/multi-user.target.wants/*;\
 rm -f /etc/systemd/system/*.wants/*;\
 rm -f /lib/systemd/system/local-fs.target.wants/*; \
 rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
 rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
 rm -f /lib/systemd/system/basic.target.wants/*;\
 rm -f /lib/systemd/system/anaconda.target.wants/*;

FROM top

RUN echo '\n\
function getservices { systemctl list-units --type=service; }\n\
function getactive { systemctl list-units --type=service --state=active; }\n\
function getinactive { systemctl list-units --type=service --state=inactive; }\n\
function getdead { getinactive|grep dead; }\n\
function getrunning { systemctl list-units --type=service --state=running; }\n'\
>> /root/.bashrx


VOLUME [ "/sys/fs/cgroup" ]
CMD ["/sbin/init"]

RUN apt-get -qq clean
