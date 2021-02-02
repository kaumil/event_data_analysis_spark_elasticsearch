#!/bin/bash
useradd nifi
hdfs dfs -mkdir /dfs-data
hdfs dfs -chown nifi: /dfs-data
hdfs dfs -chmod -R 777 /dfs-data
useradd jovyan
hdfs dfs -mkdir /csv-data
hdfs dfs -chown jovyan: /csv-data
hdfs dfs -chmod -R 777 /csv-data
exit