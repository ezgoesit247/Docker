FROM local/u18-jdk8header


RUN echo '\n\
if [ -d /apache-activemq-5.16.0 ];\n\
then green "$(/apache-activemq-5.16.0/bin/activemq start)"; echo;\n\
else grey "apache-activemq not mounted, not installed"; echo;\n\
fi;\n\
'\
>> /etc/bash.bashrc

RUN apt-get -qq clean
