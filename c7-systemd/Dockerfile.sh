FROM local/c7-systemd
CMD ["/sbin/init"]

### RUN CONTAINER WITH THIS COMMAND:
#  docker run --privileged -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro --rm c7-systemd
# THEN CONNECT WITH THIS COMMAND:
#  docker exec -it <GUID_RETURNED_ABOVE> sh
#
### WRAPPED INTO A ONE-LINER:
#  docker exec -it `docker run --privileged -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name systemd c7-systemd` /bin/bash
