# HOWTO readme file

This is a work directory. The docker file installs hadoop on top of u18-developer.
spark-master is FROM bde2020/spark-master:3.0.1-hadoop3.2
spark-worker is FROM bde2020/spark-worker:3.0.1-hadoop3.2
spark-scala-submit is HARDLINKED FROM bde2020/spark-submit:3.0.1-hadoop3.2

# Docker Spark Cluster
Spark cluster stems from base @ [Big Data Europe](https://github.com/big-data-europe/docker-spark), which runs from Alpine Linux
** base
   Copies: wait-for.sh, execute.sh, finish.sh
   Installs java, python,... etc
   No CMD
** master
   Copies: master.sh
   Exposes ports 8080 7077 6066
   CMD runs master.sh
   ** master.sh
      runs: spark-config.sh
      runs: load-spark-env.sh
** worker
   Copies: worker.sh
   Exposes ports 8081
   CMD runs worker.sh
   ** worker.sh
      runs: spark-config.sh
      runs: load-spark-env.sh
** submit
   Copies: submit.sh
   CMD runs submit.sh
   ** submit.sh
      Executes wait-for.sh
      Executes execute.sh
      Does a file check
      Executes /spark/bin/spark-submit
      Executes finish.sh
** scala-submit extends submit
   Installs Scala Build Tool (sbt
   Copies template.sh
   CMD Executes template.sh
      ** template.sh
      Looks in /app/target for jar *-assembly-*.jar
      Executes submit.sh
