#progress$
docker-compose up -d
cat>./input.txt<<EOF
In as name to here them deny wise this. As rapid woody my he me which. Men but they fail shew just wish next put. Led all visitor musical calling nor her. Within coming figure sex things are. Pretended concluded did repulsive education smallness yet yet described. Had countryman his pressed shewing. No gate dare rose he. Eyes year if miss he as upon.
EOF
docker cp ./input.txt spark-master:/data/
connect spark-master

#spark-master$
spark-shell --master spark://spark-master:7077 --total-executor-cores 1 --executor-memory 1024m

#spark-shell$
val inputfile = sc.textFile("/data/input.txt")
val counts = inputfile.flatMap(line => line.split(" ")).map(word => (word, 1)).reduceByKey (_+_)
counts.saveAsTextFile("/data/output")
