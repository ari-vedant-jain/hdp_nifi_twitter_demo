echo "Creating Hbase table with thresholds"
/usr/hdp/current/phoenix-client/bin/psql.py localhost:2181:/hbase-unsecure /root/oldFiles/fetchSecuritiesList/runcreatehbasetables.sh/fetchSecuritiesList/hbase-createstockthresholds.sql /root/oldFiles/fetchSecuritiesList/runcreatehbasetables.sh/fetchSecuritiesList/securities.csv

