FROM local/c7-systemd
RUN yum -y update \
   && yum install -y -q yum-utils python3 \
   && yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
   && yum install -y -q docker-ce docker-ce-cli containerd.io
RUN curl -sL "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
   && chmod +x /usr/local/bin/docker-compose
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
CMD ["/sbin/init"]


### RUN CONTAINER WITH THIS COMMAND:
#  docker run --privileged -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro --rm c7-systemd
# THEN CONNECT WITH THIS COMMAND:
#  docker exec -it <GUID_RETURNED_ABOVE> sh
#
### WRAPPED INTO A ONE-LINER:
#  docker exec -it `docker run --privileged -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name systemd c7-systemd` /bin/bash
