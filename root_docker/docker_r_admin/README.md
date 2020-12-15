#RUN HERE (ANYWHERE, REALLY ;-)
docker run --privileged -it -P \
  -v ${PWD}:/root/_assets \
  -v ${HOME}/Docker/_shared_assets:/root/_shared_assets \
  -v ${HOME}/.m2:/root/.m2 \
  -v ${HOME}/.aws:/root/.aws \
  -v ${HOME}/.ssh:/root/.ssh \
  -w /root \
  --rm docker_admin

#RUN
docker run --privileged -it \
  -v ${HOME}/Docker/_shared_assets:/root/assets \
  -p 8080:8080 \
  --name ${PWD##*/} \
  ${PWD##*/}

#RUN REMOVE
docker run --privileged -it \
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

#START attach
docker start ${PWD##*/} && docker attach $_

#BUILD IMAGE
docker build -t ${PWD##*/} .
