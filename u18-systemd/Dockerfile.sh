FROM local/u18-seed
ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

USER root
WORKDIR /root
ENV DOCKER_ENV=default
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


#RUN cd /lib/systemd/system/sysinit.target.wants/ \
#    && ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1

#RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
#    /etc/systemd/system/*.wants/* \
#    /lib/systemd/system/local-fs.target.wants/* \
#    /lib/systemd/system/sockets.target.wants/*udev* \
#    /lib/systemd/system/sockets.target.wants/*initctl* \
#    /lib/systemd/system/basic.target.wants/* \
#    /lib/systemd/system/anaconda.target.wants/* \
#    /lib/systemd/system/plymouth* \
#    /lib/systemd/system/systemd-update-utmp*


VOLUME [ "/sys/fs/cgroup" ]
CMD ["/sbin/init"]
