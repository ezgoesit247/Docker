
##  docker exec -it $(docker run -d --rm --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro local/centos-systemd) /bin/bash

FROM centos:8 as tmp1

RUN echo -e "\
alias ls=\"ls -Altr --color=auto\" \n\
grep PRETTY_NAME /etc/os-release|sed \"s/[\\\"=_PRETTYNAME]//g\" \n\
"\
>>/root/.bashrc


ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]
RUN yum clean all
