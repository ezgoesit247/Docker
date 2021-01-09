FROM alpine:3.12

ARG VERSION
ARG VAR
RUN echo "$VAR:$VERSION" > /versionfile.txt
CMD cat /versionfile.txt

### BUILD  build --arg=VAR=cheesse --arg=VERSION=21
###   RUN  run
