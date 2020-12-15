#RUN HERE (ANYWHERE, REALLY ;-)
docker run -it -P \
  -v ${PWD}:/root/assets \
  -v ${HOME}/.m2:/root/.m2 \
  -v ${HOME}/.aws:/root/.aws \
  --rm ${src_dir}

#RUN NAMED
docker run -it -P \
  -v ${HOME}/Docker/shared_assets:/root/assets \
  -v ${HOME}/Docker/shared_assets/bash_history:/root/bash_history \
  -v ${HOME}/.m2:/root/.m2 \
  -v ${HOME}/.aws:/root/.aws \
  -v ${HOME}/eclipse-workspace:/root/eclipse-workspace \
  -v ${HOME}/git_clone:/root/git_clone \
  --name ${PWD##*/} \
  ${PWD##*/}

#RUN REMOVE
docker run -it -P \
  -v ${HOME}/Docker/shared_assets:/root/assets \
  -v ${HOME}/Docker/shared_assets/bash_history:/root/bash_history \
  -v ${HOME}/.m2:/root/.m2 \
  -v ${HOME}/.aws:/root/.aws \
  -v ${HOME}/eclipse-workspace:/root/eclipse-workspace \
  -v ${HOME}/git_clone:/root/git_clone \
  --rm ${PWD##*/}

#START attach
docker start ${PWD##*/} && docker attach ${_}

#BUILD IMAGE
docker build -t ${PWD##*/} .

