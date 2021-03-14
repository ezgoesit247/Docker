FROM nginx AS tmp1



FROM tmp1
COPY assets.docker/10-listen-on-ipv6-by-default.sh /docker-entrypoint.d/
COPY assets.docker/20-envsubst-on-templates.sh /docker-entrypoint.d/
RUN chmod u+x docker-entrypoint.d/*
