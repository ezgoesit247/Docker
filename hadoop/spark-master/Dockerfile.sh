FROM bde2020/spark-master:3.0.1-hadoop3.2

ENV PS1="\[\033[0;34m\]\h\[\033[0m\] \[\033[0;32m\]\d \T\[\033[0m\] \[\033[0;33m\]\w\[\033[0m\]\$ "
ENV PATH="${PATH}::/spark/bin/"

### START SPARK SHELL ###
#
# spark-shell --master spark://spark-master:7077 --total-executor-cores 6 --executor-memory 5120m
#
###
