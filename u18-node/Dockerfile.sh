FROM local/u18-developer
### NODE ###
RUN sudo apt-get install -qq gnupg2 \
   && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
   && echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list \
   && sudo apt-get install -qq \
      yarn \
   && git clone https://github.com/nvm-sh/nvm.git /home/poweruser/.nvm
RUN   echo '### NODE ###\n \
   pushd /home/poweruser/.nvm\n \
   git pull\n \
   popd\n \
   if  ! command -v nvm > /dev/null; then\n \
   . /home/poweruser/.nvm/nvm.sh\n \
   export NVM_DIR="$HOME/.nvm"\n \
   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm\n \
   [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion\n \
   fi\n \
   function nodever() { if [ ! -z $1 ]; then nvm install ${1} > /dev/null 2>&1 && nvm use ${_} > /dev/null 2>&1 && nvm alias default ${_} > /dev/null 2>&1; blue "Node:"; node -v; else echo -e " usage: nodedef ver\n\tinstall or switch node versions, currently:"; blue "Node:"; node -v; fi; }\n \
   if command -v nvm > /dev/null  && ! command -v node; then blue "nvm:";nvm install --lts; fi\n \
   blue "Node:"; node -v \n \
   ' >> /home/poweruser/.bashrc

RUN sudo apt-get -qq clean
