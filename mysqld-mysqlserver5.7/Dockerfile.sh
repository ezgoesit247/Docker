FROM mysql/mysql-server:5.7

#VOLUME ["/mysql-server-volume"]
EXPOSE 3306:3306

###  CASE #1
###   cd ${HOME}/Docker/mysql-server
###   build
###   docker volume create mysql-server-volume
###   docker run -p3306:3306 -v mysql-server-volume:/var/lib/mysql -d -e MYSQL_ROOT_PASSWORD=P@ssw0rd! --name mysqld mysqld
###   docker exec -it mysqld mysql -uroot -pP@ssw0rd!
###
###  CASE #2
###   docker run -p3306:3306 -v mysql-server-volume:/var/lib/mysql -d --name mysqld mysqld
###   docker start mysqld && sleep 2 && docker exec -it mysqld mysql -uroot -pP@ssw0rd!
###
