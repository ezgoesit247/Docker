#BUILD IMAGE
docker build -t ${PWD##*/} .

#RUN MOUNTED VOLUME
docker run -it \
  --mount source=data_share,destination=/root/mounted_vol \
  --rm ${PWD##*/}

#RUN
docker run -it \
  -v ${HOME}/assets:/root/assets \
  -p 8080:8080 \
  --rm ${PWD##*/}
