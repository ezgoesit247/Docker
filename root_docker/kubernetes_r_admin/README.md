#RUN HERE (ANYWHERE, REALLY ;-)
docker run --privileged -it -P \
  -v ${PWD}:/root/assets \
  -v ${HOME}/.m2:/root/.m2 \
  -v ${HOME}/.aws:/root/.aws \
  -w /root \
  --rm kubernetes_admin

#RUN
docker run --privileged -it -P \
  -v ${HOME}/Docker/_shared_assets:/root/assets \
  -v ${HOME}/Docker/_shared_assets/bash_history:/root/bash_history \
  -v ${HOME}/.m2:/root/.m2 \
  -v ${HOME}/.aws:/root/.aws \
  -v ${HOME}/eclipse-workspace:/root/eclipse-workspace \
  -v ${HOME}/git_clone:/root/git_clone \
  -w /root \
  --rm ${PWD##*/}

#RUN NAMED
docker run --privileged -it -P \
  -v ${HOME}/Docker/_shared_assets:/root/assets \
  -v ${HOME}/Docker/_shared_assets/bash_history:/root/bash_history \
  -v ${HOME}/.m2:/root/.m2 \
  -v ${HOME}/.aws:/root/.aws \
  -v ${HOME}/eclipse-workspace:/root/eclipse-workspace \
  -v ${HOME}/git_clone:/root/git_clone \
  --name ${PWD##*/}1 \
  -w /root \
   ${PWD##*/}

#RUN REMOVE
docker run --privileged -it \
  -v ${HOME}/Docker/_shared_assets:/root/assets \
  -v ${HOME}/Docker/_shared_assets/bash_history:/root/bash_history \
  -v ${HOME}/.m2:/root/.m2 \
  -v ${HOME}/.aws:/root/.aws \
  -v ${HOME}/eclipse-workspace:/root/eclipse-workspace \
  -v ${HOME}/git_clone:/root/git_clone \
  -p 3000:3000 \
  -p 8000:8000 \
  -p 8001:8001 \
  -p 8080:8080 \
  -p 8883:8883 \
  -w /root \
  --rm ${PWD##*/}

#START attach
docker start ${PWD##*/} && docker attach $_

#BUILD IMAGE
docker build -t ${PWD##*/} .
