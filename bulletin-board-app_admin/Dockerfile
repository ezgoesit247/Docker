###
# BUILD:      docker build --tag bulletinboard:port8063 .
# RUN:        docker run --publish 8036:8063 --detach --name bb bulletinboard:port8063
# NAVIGATE:   http://localhost:8036
#
###
FROM bulletinboard:1.0

WORKDIR /usr/src/app
COPY package.json .
RUN npm install

EXPOSE 8063
CMD [ "npm", "start" ]

COPY . .
