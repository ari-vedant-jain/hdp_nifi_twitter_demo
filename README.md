## NiFi Twitter Storm Demo with Banana Visualization


Thanks to [Ryan Templeton](https://github.com/rtempleton) for their help with troubleshooting. 

This Demo is built for Hortonworks HDP 2.3 Sandbox. 
------------------
This is based on the [Hortonworks Twitter Demo](https://github.com/hortonworks-gallery/hdp22-twitter-demo) 
#### Purpose: Monitor Twitter stream for the procided Hastags & act on unexpected increases in tweet volume

- Ingest: 
Listen for Twitter streams related to Hashtags input in NiFi Garden Hose (GetHTTP) processor 
- Processing:
  - Monitor tweets for unexpected volume
  - Volume thresholds managed in HBASE
- Persistence:
  - HDFS (for future batch processing)
  - Hive (for interactive query) 
  - HBase (for realtime alerts)
  - Solr/Banana (for search and reports/dashboards)
- Refine:
  -  Update threshold values based on historical analysis of tweet volumes

- Demo setup:
	- Either download and start prebuilt VM
	- Start HDP 2.3 sandbox and run provided scripts to setup demo 


------------------
	
<!--#### Contents-->

<!--1. [Option 1: Setup demo using prebuilt VM based on HDP 2.3 sandbox](https://github.com/hortonworks-gallery/hdp22-twitter-demo#option-1-setup-demo-using-prebuilt-vm-based-on-hdp-23-sandbox)-->
<!--2. [Option 2: Setup demo via scripts on vanilla HDP 2.3 sandbox](https://github.com/hortonworks-gallery/hdp22-twitter-demo#option-2-setup-demo-via-scripts-on-vanilla-hdp-23-sandbox)-->
<!--3. [Kafka basics - optional](https://github.com/hortonworks-gallery/hdp22-twitter-demo#kafka-basics---optional)-->
<!--4. [Run demo](https://github.com/hortonworks-gallery/hdp22-twitter-demo#run-twitter-demo) to monitor Tweets about S&P 500 securities in realtime-->
<!--5. [Stop demo](https://github.com/hortonworks-gallery/hdp22-twitter-demo#to-stop-collecting-tweets)-->
<!--5. [Troubleshooting](https://github.com/hortonworks-gallery/hdp22-twitter-demo#troubleshooting)-->
<!--6. [Observe results](https://github.com/hortonworks-gallery/hdp22-twitter-demo#observe-results) in HDFS, Hive, Solr/Banana, HBase-->
<!--7. [Use Zeppelin to create charts to analyze tweets - optional](https://github.com/hortonworks-gallery/hdp22-twitter-demo#use-zeppelin-to-create-charts-to-analyze-tweets)-->
<!--8. [Import data into BI tools - optional](https://github.com/hortonworks-gallery/hdp22-twitter-demo#import-data-to-bi-tool-via-odbc-for-analysis---optional)-->
<!--9. [Other things to try - optional](https://github.com/hortonworks-gallery/hdp22-twitter-demo#other-things-to-try-analyze-any-kind-of-tweet---optional)-->
<!--10. [Reset demo](https://github.com/hortonworks-gallery/hdp22-twitter-demo#reset-demo)-->
<!--11. [Run demo on cluster](https://github.com/hortonworks-gallery/hdp22-twitter-demo#run-demo-on-cluster)-->

---------------------
 
#### Option 1: Setup demo using prebuilt VM based on HDP 2.3 sandbox

- Download VM from [here](). Import it into VMWare Fusion and start it up. 
- Find the IP address of the VM and add an entry into your machines hosts file e.g.
```
192.168.191.133 sandbox.hortonworks.com sandbox    
```
- Connect to the VM via SSH (password hadoop)
```
ssh root@sandbox.hortonworks.com
```
- Start the demo by
```
cd /root/hdp_nifi_twitter_demo
./start-demo.sh
#once storm topology is submitted, press control-C

#start Nifi processor

1. Using Browser, go to http://sandbox.hortonworks.com:<port#>/nifi
2. Upload the XML file into NiFi templates section in the UI. The XML file is under /root/hdp_nifi_twitter_demo/nifi-template
```
- [Observe results](https://github.com/hortonworks-gallery/hdp22-twitter-demo#observe-results) in HDFS, Hive, Solr/Banana, HBase

- Troubleshooting: check the [Storm webUI](http://sandbox.hortonworks.com:8744) for any errors and try resetting using below script:
```
./reset-demo.sh
```

-------------------------


#### Option 2: Setup demo via scripts on vanilla HDP 2.3 sandbox

These setup steps are only needed first time and may take upto 30min to execute (depending on your internet connection)

- Download HDP 2.3 sandbox VM image file (Sandbox_HDP_2.3_VMWare.ova) from [Hortonworks website](http://hortonworks.com/products/hortonworks-sandbox/) 
- Find the IP address of the VM and add an entry into your machines hosts file e.g.
```
192.168.191.241 sandbox.hortonworks.com sandbox    
```
- Connect to the VM via SSH (password hadoop)
```
ssh root@sandbox.hortonworks.com
```

- Pull latest code/scripts
```
git clone git@github.com:vedantja/hdp_nifi_twitter_demo.git

```
    
- NiFi Garden Hose Processor requires you to have a Twitter account and obtain developer keys by registering an "app". Create a Twitter account and app and get your consumer key/token and access keys/tokens:
https://apps.twitter.com > sign in > create new app > fill anything > create access tokens
- Then enter the 4 values into the appropriate fields (see screenshot)
```
consumerKey
consumerSecret
oauth.accessToken
oauth.accessTokenSecret
```

- Run below to setup demo (one time): start Ambari/HBase/Kafka/Storm and install maven, solr, banana -may take 10 min
```
cd /root/hdp22-twitter-demo
./setup-demo.sh
```

------------------


<!--##### Kafka basics - (optional)-->

<!--```-->
<!--#check if kafka already started-->
<!--ps -ef | grep kafka-->

<!--#if not, start kafka-->
<!--nohup /usr/hdp/current/kafka-broker/bin/kafka-server-start.sh /usr/hdp/current/kafka-broker/config/server.properties &-->

<!--#create topic-->
<!--/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test-->

<!--#list topic-->
<!--/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --zookeeper localhost:2181 --list | grep test-->

<!--#start a producer and enter text on few lines-->
<!--/usr/hdp/current/kafka-broker/bin/kafka-console-producer.sh --broker-list localhost:6667 --topic test-->

<!--#start a consumer in a new terminal your text appears in the consumer-->
<!--/usr/hdp/current/kafka-broker/bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic test --from-beginning-->

<!--#delete topic-->
<!--/usr/hdp/current/kafka-broker/bin/kafka-run-class.sh kafka.admin.DeleteTopicCommand --zookeeper localhost:2181 --topic test-->
<!--```-->
<!----------------------------------->

#####  Run Twitter demo 

Most of the below steps are optional as they were already executed by the setup script above but are useful to understand the components of the demo:

- (Optional) Review the list of stock symbols whose Twitter mentiones we will be tracking
http://en.wikipedia.org/wiki/List_of_S%26P_500_companies

- (Optional) Generate securities csv from above page and review the securities.csv generated. The last field is the generated tweet volume threshold 
```
/root/hdp_nifi_twitter_demo/fetchSecuritiesList/rungeneratecsv.sh
cat /root/hdp_nifi_twitter_demo/fetchSecuritiesList/securities.csv
```

- (Optional) for future runs: you can add other stocks/hashtags to monitor to the csv (make sure no trailing spaces/new lines at the end of the file). Find these at http://mobile.twitter.com/trends
```
sed -i '1i$HDP,Hortonworks,Technology,Technology,Santa Clara CA,0000000001,5' /root/hdp22-twitter-demo/fetchSecuritiesList/securities.csv
sed -i '1i#hadoopsummit,Hadoop Summit,Hadoop,Hadoop,Santa Clara CA,0000000001,5' /root/hdp22-twitter-demo/fetchSecuritiesList/securities.csv
```

- (Optional) Open connection to HBase via Phoenix and check you can list tables. Notice securities data was imported and alerts table is empty
```
/usr/hdp/current/phoenix-client/bin/sqlline.py  localhost:2181:/hbase-unsecure
!tables
select * from securities;
select * from alerts;
select * from dictionary;
!q
```

- (Optional) check Hive table schema where we will store the tweets for later analysis
```
hive -e 'desc tweets_text_partition'
```

- **Start Storm Twitter topology** to generate alerts into an HBase table for stocks whose tweet volume is higher than threshold this will also read tweets into Hive/HDFS/local disk/Solr/Banana. The first time you run below, maven will take 15min to download dependent jars
```
cd /root/hdp_nifi_twitter_demo
./start-demo.sh
#once storm topology is submitted, press control-C
```

- (Optional) Other modes the topology could be started in future runs if you want to clean the setup or run locally (not on the storm running on the sandbox)
```
cd /root/hdp_nifi_twitter_demo/twitterstorm
./runtopology.sh runOnCluster clean
./runtopology.sh runLocally skipclean
```

- open storm UI and confirm topology was created
http://sandbox.hortonworks.com:8744/

<!--
- **Start Kafka producer**: In a new terminal, compile and run kafka producer to start producing tweets containing first 400 stock symbols values from csv
```
/root/hdp22-twitter-demo/kafkaproducer/runkafkaproducer.sh
```
-->
------------------


#### To stop collecting tweets:
- To stop producing tweets, hit the stop button on the template processor in the NiFi console. 

- kill the storm topology to stop processing tweets
```
storm kill Twittertopology
```

------------------


	
