#!/bin/bash
FROM ubuntu:20.04 as seedling
CMD [ "/bin/bash" ]

RUN apt-get -qq update \
&& apt-get clean

FROM seedling as rootstuff
RUN echo '### ROOT STUFF ###\n\
alias ls="ls -Altr --color=auto"\n\
export PS1="\\[\\033[1;32m\\]\\u\\[\\033[0m\\]@\\[\\033[1;31m\\]\\h:\\[\\033[0;37m\\]\\w\\[\\033[0m\\]\\$ " \n\
export HISTTIMEFORMAT="%FT%T\t"\n\
'\
>>/root/.bashrc
