FROM docker_admin

RUN apt-get -y update && apt-get -y upgrade

RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
RUN cd -

RUN  echo 'cyan "helm"; helm version --short' >> ~/.bashrc \
&& echo 'export PATH=${PATH}:/root/assets' >> ~/.bashrc
