### BUILT WITH dosetup
FROM local/ubuntu-appdev:18.04 as root
ARG gituser
ARG CUSERHOME=/root

ENV GIT_SSH=/root/bin/git-ssh
ARG ROOT_SAFE_PATH=\\/root
ARG GIT_CONFIG=/root/.gitconfig
ARG KNOWN_HOSTS=/root/.ssh/known_hosts
COPY assets.docker/git-ssh $GIT_SSH
COPY assets.docker/git-ssh $GIT_SSH
COPY assets.docker/.gitconfig $GIT_CONFIG
COPY assets.docker/known_hosts $KNOWN_HOSTS

ARG SSH_PRIVATE_KEY
ARG SSH_PRIVATE_KEY_STREAM
RUN echo "${SSH_PRIVATE_KEY_STREAM}" > /root/.ssh/$SSH_PRIVATE_KEY

RUN chmod 700 /root/.ssh && chmod 755 /root/bin && chmod 755 $GIT_SSH && chmod 600 $KNOWN_HOSTS && chmod 644 $GIT_CONFIG && sed -i 's/\/Users\/***REMOVED***/'$ROOT_SAFE_PATH'/' $GIT_CONFIG && chmod 600 /root/.ssh/$SSH_PRIVATE_KEY

VOLUME /mesen
RUN git clone git@github.com:$gituser/mesen /mesen && ln -fsn /mesen $CUSERHOME/mesen
RUN apt-get -qq clean


ARG DOCKER_ENV=mesen
ENV DOCKER_ENV=$DOCKER_ENV

FROM root as builddeps
RUN apt install -y zip && \
apt install -y clang-7 && \
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-7 70 && \
update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-7 70 && \
apt install -y gnupg ca-certificates && \
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list && \
apt update && \
apt install -y mono-devel && \
apt install -y libsdl2-dev

#FROM builddeps as x11docker
#RUN apt-get install -qq xpra xserver-xephyr xinit xauth xclip x11-xserver-utils x11-utils && \
#curl -fsSL https://raw.githubusercontent.com/mviereck/x11docker/master/x11docker | bash -s -- --update

FROM builddeps as x11
VOLUME /root/.config/mesen
RUN apt-get install -y x11-apps && \
rm -rf /tmp/* /usr/share/doc/* /usr/share/info/* /var/tmp/* && \
mkdir -p /root/.config/mesen
ENV DISPLAY :0

FROM x11 as runmesen
RUN echo '/usr/bin/make run\n\
'\
>>/root/.bashrc
