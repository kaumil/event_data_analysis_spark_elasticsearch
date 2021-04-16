FROM jupyter/pyspark-notebook
RUN wget https://artifacts.elastic.co/downloads/elasticsearch-hadoop/elasticsearch-hadoop-7.11.1.zip -P /home/jovyan
RUN unzip elasticsearch-hadoop-7.11.1.zip
RUN pip install hdfs
RUN pip install elasticsearch