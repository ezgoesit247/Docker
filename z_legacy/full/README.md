#BUILD IMAGE
docker build -t ${PWD##*/} .

#RUN HERE (ANYWHERE, REALLY ;-)
docker run --privileged -it -P \
  -v ${PWD}:/home/poweruser/_assets \
  -v ${HOME}/Docker/_shared_assets:/home/poweruser/_shared_assets \
  -v ${HOME}/.m2:/home/poweruser/.m2 \
  -v ${HOME}/.aws:/home/poweruser/.aws \
  -v ${HOME}/.ssh:/home/poweruser/.ssh \
  --user poweruser \
  --rm full

#RUN
docker run -it \
  -v ${HOME}/Docker/_shared_assets:/home/poweruser/assets \
  -p 8080:8080 \
  --name ${PWD##*/} \
  ${PWD##*/}

#RUN REMOVE
docker run -it \
  -v ${HOME}/Docker/_shared_assets:/home/poweruser/assets \
  -v ${HOME}/.m2:/home/poweruser/.m2 \
  -v ${HOME}/.aws:/home/poweruser/.aws \
  -v ${HOME}/eclipse-workspace:/home/poweruser/eclipse-workspace \
  -v ${HOME}/git_clone:/home/poweruser/git_clone \
  -p 3000:3000 \
  -p 8000:8000 \
  -p 8080:8080 \
  -p 8883:8883 \
  --rm ${PWD##*/}

#START attach
docker start ${PWD##*/} && docker attach $_
