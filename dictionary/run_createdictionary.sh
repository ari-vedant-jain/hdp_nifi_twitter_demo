echo "Creating Hbase table with dictionary"
/usr/hdp/current/phoenix-client/bin/psql.py  localhost:2181:/hbase-unsecure /root/hdp_nifi_twitter_demo/dictionary/hbase-createdictionary.sql /root/hdp_nifi_twitter_demo/dictionary/dictionary.csv

