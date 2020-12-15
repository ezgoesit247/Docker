#BUILD IMAGE
docker build -t ${PWD##*/} .

#RUN HERE (ANYWHERE, REALLY ;-)
docker run -it -P \
  -v ${PWD}:/home/poweruser/_assets.local \
  -v ${HOME}/Docker/_shared_assets:/home/poweruser/_assets \
  --user poweruser \
  --name user --rm \
   user

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
