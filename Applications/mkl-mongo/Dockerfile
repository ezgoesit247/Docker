#!/bin/bash
### GENERATED BY: dosetup
FROM local/seedling:ubuntu as mkl-mongo

### EMBED_USER ###
RUN apt-get update && apt-get install -qq sudo curl vim
RUN echo "ALL ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers
ARG gituser
RUN groupadd -g 1000 $gituser && useradd -ms /bin/bash -u 1000 -g 1000 $gituser
USER $gituser
WORKDIR /home/$gituser
RUN echo 'export PS1="\\[\\033[1;34m\\]\\u\\[\\033[0m\\]@\\[\\033[1;31m\\]\\h:\\[\\033[0;37m\\]\\w\\[\\033[0m\\] \$ "\nalias ls="ls -Altr --color=auto"\n'>>~/.bashrc
CMD [ "/bin/bash" ]
FROM mkl-mongo as mkl-mongopackages

### EMBED_MONGODB ###
VOLUME mkl-mongo
RUN sudo mkdir -p /mkl-mongo/lib/mongo && sudo mkdir -p /mkl-mongo/log/mongodb && sudo chown -R 1000:1000 /mkl-mongo && ln -s /mkl-mongo ~/mkl-mongo
ARG MONGO_DIR=/usr/local/mongo
ARG MONGO_BIN_DIR=/usr/bin
ARG MONGO=https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu2004-4.4.6.tgz
COPY assets.mongo/mongodb.service /etc/init.d/mongodb
RUN sudo mkdir -p $MONGO_DIR && curl -s $MONGO | sudo tar zxv --strip-components=1 -C $MONGO_DIR && sudo ln -fn $MONGO_DIR/bin/mongo $MONGO_BIN_DIR && sudo ln -fn $MONGO_DIR/bin/mongos $MONGO_BIN_DIR && sudo ln -fn $MONGO_DIR/bin/mongod $MONGO_BIN_DIR
RUN sudo mkdir -p /var/lib/mongo  && sudo mkdir -p /var/log/mongodb && sudo chown $(whoami) /var/lib/mongo && sudo chown $(whoami) /var/log/mongodb
RUN sudo ln $MONGO_DIR/bin/mongo /usr/local/sbin/ && sudo ln $MONGO_DIR/bin/mongod /usr/local/sbin/ && sudo ln $MONGO_DIR/bin/mongos /usr/local/sbin/
RUN sudo chmod 755 /etc/init.d/mongodb && cd /etc/rc3.d/ && sudo ln -fsn ../init.d/mongodb S01mongodb && cd /etc/rc4.d/ && sudo ln -fsn ../init.d/mongodb S01mongodb && cd /etc/rc5.d/ && sudo ln -fsn ../init.d/mongodb S01mongodb


### MONGO_USER ###
ARG mongo_user="\
use admin\
db.createUser( {\
user: \"MONGOUSERENAME\",\
pwd: \"MONGOUSERPASSWORD\",\
roles: [ { role: \"userAdminAnyDatabase\", db: \"admin\" } ]\
} )"
RUN mkdir -p ~/mongo_setup && echo $mongo_user >~/mongo_setup/mongo_user.in.mongo
ARG MONGOOSE="#!/bin/sh\nnpm install mongoose"
RUN echo -e $MONGOOSE >~/mongo_setup/mongoose


RUN sudo apt-get clean
