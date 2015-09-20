echo "Creating Hbase table with thresholds"
/usr/hdp/current/phoenix-client/bin/psql.py localhost:2181:/hbase-unsecure /root/hdp_nifi_twitter_demo/fetchSecuritiesList/hbase-createstockthresholds.sql /root/hdp_nifi_twitter_demo/fetchSecuritiesList/securities.csv

