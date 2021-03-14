FROM centos:7
RUN echo "cat /etc/centos-release" >> /etc/bashrc
CMD ["/bin/bash"]
