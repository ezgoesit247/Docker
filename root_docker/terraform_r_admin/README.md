#RUN HERE (ANYWHERE, REALLY ;-)
docker run -it -P \
  -v ${PWD}:/root/assets \
  -v ${HOME}/.m2:/root/.m2 \
  -v ${HOME}/.aws:/root/.aws \
  -w /root \
  --rm terraform_admin

#RUN REMOVE
docker run --privileged -it -P \
  -v ${HOME}/Docker/_shared_assets:/root/assets \
  -v ${HOME}/Docker/_shared_assets/bash_history:/root/bash_history \
  -v ${HOME}/.m2:/root/.m2 \
  -v ${HOME}/.aws:/root/.aws \
  -v ${HOME}/eclipse-workspace:/root/eclipse-workspace \
  -v ${HOME}/git_clone:/root/git_clone \
  --rm ${PWD##*/}

#START ATTACH
docker start ${PWD##*/} && docker attach $_

#HELPERS
trial=0
trial=`expr ${trial} + 1`;docker build -t ${PWD##*/}${trial} .
docker run --privileged -it -v `pwd`/assets:/root/assets --name ${PWD##*/}${trial} --rm ${PWD##*/}${trial}


docker start ${PWD##*/}${trial} && ${PWD##*/}${trial} attach $_

#REMOVE IMAGE
docker rmi ${PWD##*/}

#REMOVE CONTAINER

#BUILD IMAGE
docker build -t ${PWD##*/} .
