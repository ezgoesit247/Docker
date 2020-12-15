#RUN HERE (ANYWHERE, REALLY ;-)
docker run -it -P \
  -v ${PWD}:/root/_assets \
  -v ${HOME}/Docker/_shared_assets:/root/_shared_assets \
  -v ${HOME}/.m2:/root/.m2 \
  -v ${HOME}/.aws:/root/.aws \
  -v ${HOME}/.ssh:/root/.ssh \
  -w /root \
  --rm development_admin


#RUN
docker run -it \
  -v ${HOME}/Docker/_shared_assets:/root/assets \
  -v ${HOME}/.m2:/root/.m2 \
  -v ${HOME}/.aws:/root/.aws \
  -v ${HOME}/eclipse-workspace:/root/eclipse-workspace \
  -v ${HOME}/git_clone:/root/git_clone \
  -w /root \
  -P \
  --rm ${PWD##*/}

#RUN NAMED IMAGE
docker run -it \
  -v ${HOME}/Docker/_shared_assets:/root/assets \
  -v ${HOME}/.m2:/root/.m2 \
  -v ${HOME}/.aws:/root/.aws \
  -v ${HOME}/eclipse-workspace:/root/eclipse-workspace \
  -v ${HOME}/git_clone:/root/git_clone \
  -p 3000:3000 \
  -p 8000:8000 \
  -p 8080:8080 \
  -p 8883:8883 \
\
  -v ${HOME}/Docker/_shared_assets/apache-activemq-5.16.0:/apache-activemq-5.16.0 \
  -p 8161:8161 \
  -p 61616:61616 \
\
  --name ${PWD##*/} \
  -w /root \
  ${PWD##*/}

#RUN REMOVE IMAGE
docker run -it \
  -v $(pwd)/assets:/root/assets \
  -v ***REMOVED***/Docker/_shared_assets/apache-activemq-5.16.0:/apache-activemq-5.16.0 \
  -p 8161:8161 \
  -p 61616:61616 \
  --name ${PWD##*/} \
  --rm ${PWD##*/}

#START ATTACH
docker start ${PWD##*/} && docker attach ${_}

#REMOVE IMAGE
docker rmi ${PWD##*/}

#REMOVE CONTAINER

#BUILD IMAGE
docker build -t ${PWD##*/} .
