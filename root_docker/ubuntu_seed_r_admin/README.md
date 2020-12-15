#RUN
docker run  -it \
  --rm ubuntu_seed_admin

#BUILD IMAGE
docker build -t ${PWD##*/} .

#RUN IMAGE
docker run  -it \
  --rm ubuntu_seed_admin

#START ATTACH
docker start ${PWD##*/} && docker attach $_

#REMOVE IMAGE
docker rmi ${PWD##*/}

#REMOVE CONTAINER
