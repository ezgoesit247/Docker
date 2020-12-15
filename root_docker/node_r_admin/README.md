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
  --name ${PWD##*/} \
  ${PWD##*/}

#RUN REMOVE IMAGE
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
  --rm ${PWD##*/}

#START ATTACH
docker start ${PWD##*/} && docker attach $_

#REMOVE IMAGE
docker rmi ${PWD##*/}

#REMOVE CONTAINER

#BUILD IMAGE
docker build -t ${PWD##*/} .
