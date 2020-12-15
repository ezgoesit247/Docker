FROM development_admin


RUN apt-get -y update && apt-get -y upgrade \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get -y install \
    yarn

RUN git clone https://github.com/nvm-sh/nvm.git /root/.nvm \
&& echo 'if  ! command -v nvm > /dev/null; then' >> /root/.bashrc \
&& echo '. /root/.nvm/nvm.sh' >> /root/.bashrc \
&& echo 'export NVM_DIR="$HOME/.nvm"' >> /root/.bashrc \
&& echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> /root/.bashrc \
&& echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> /root/.bashrc \
&& echo 'fi' >> /root/.bashrc \
&& echo 'function nodedef() { if [ ! -z $1 ]; then nvm install ${1} > /dev/null 2>&1 && nvm use ${_} > /dev/null 2>&1 && nvm alias default ${_} > /dev/null 2>&1; color 6 4 "Node:"; node -v; else echo usage: nodedef ver; fi; }' >> /root/.bashrc \
&& echo 'if  command -v nvm > /dev/null  && ! command -v node; then nvm install --lts' >> /root/.bashrc \
&& echo 'else color 6 4 "Node:"; node -v ' >> /root/.bashrc \
&& echo 'fi' >> /root/.bashrc
