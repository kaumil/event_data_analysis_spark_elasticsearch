#!/usr/bin/env python
# coding: utf-8

# In[1]:


from hdfs import InsecureClient
from pyspark.sql import SparkSession


# In[2]:


client = InsecureClient("http://hadoop:50070",user="nifi")


# In[3]:


client.list('/dfs-data')


# In[4]:


spark = (SparkSession
        .builder
        .appName("hdfsprocessor")
        .getOrCreate())


# In[6]:


df_load = spark.read.format("csv").option("delimiter", ",").option("header", "false").load(
    "hdfs://hadoop:8020/dfs-data/c32983df-9fa3-4de0-84d1-1d93fb7b9fc1")


# In[7]:


df_load.show(5)


# In[8]:


final_df = df_load.select(df_load._c0.alias('collision_id'), df_load._c1.alias('crash_date'), df_load._c2.alias('crash_time'), df_load._c3.alias('borough'), df_load._c4.alias('zip_code'), df_load._c5.alias(
    'latitude'), df_load._c6.alias('longitude'), df_load._c7.alias('on_street_name'), df_load._c9.alias('number_of_persons_injured'), df_load._c10.alias('number_of_persons_killed'), df_load._c19.alias('vehicle_type'))


# In[9]:


final_df.coalesce(1).write.format("csv").save(
    "hdfs://hadoop:8020/csv-data/abc.csv")


# In[ ]:




