set -e 


AMBARI_STARTED=`ps -ef | grep AmbariServe[r] | wc -l`
if [ ! $AMBARI_STARTED ]
then
	echo 'Starting Ambari'
	if [ -f /root/start_ambari.sh ]
	then
		/root/start_ambari.sh
	else
		ambari-server start
		ambari-agent start
	fi
	sleep 5
fi

source ambari_util.sh

if [ -e '/opt/solr' ]
then
    echo 'Moving existing Solr'
	mv /opt/solr /opt/solr-$(date +%F-%H:%M)
fi

rpmdb --rebuilddb

echo '*** Stopping OOZIE....'
stop OOZIE

echo '*** Stopping Falcon....'
stop FALCON

echo '*** Starting Hive....'
startWait HIVE

sleep 3

echo '*** Starting Storm....'
startWait STORM

sleep 3

echo '*** Starting HBase....'
startWait HBASE

sleep 3

echo '*** Starting kafka....'
startWait KAFKA

sleep 3

KAFKA_HOME=/usr/hdp/current/kafka-broker
TOPICS=`$KAFKA_HOME/bin/kafka-topics.sh --zookeeper localhost:2181 --list | wc -l`
if [ $TOPICS == 0 ]
then
	echo "No Kafka topics found...creating..."
	$KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic twitter_events	
fi

if [ ! -d '/root/hdp_nifi_twitter_demo/logs' ]
then
	mkdir /root/hdp_nifi_twitter_demo/logs
fi

find /root/hdp_nifi_twitter_demo -iname '*.sh' | xargs chmod +x
echo "Installing mvn..."
/root/hdp_nifi_twitter_demo/setup-scripts/install_mvn.sh > /root/hdp_nifi_twitter_demo/logs/install_mvn.log
echo "Installing Solr..."
/root/hdp_nifi_twitter_demo/setup-scripts/install_solr.sh > /root/hdp_nifi_twitter_demo/logs/install_solr.log
echo "Installing Banana..."
/root/hdp_nifi_twitter_demo/setup-scripts/install_banana.sh > /root/hdp_nifi_twitter_demo/logs/install_banana.log
echo "Installing Phoenix"
/root/hdp_nifi_twitter_demo/setup-scripts/install_phoenix.sh > /root/hdp_nifi_twitter_demo/logs/install_phoenix.log

echo "Creating Phoenix tables..."
/root/hdp_nifi_twitter_demo/fetchSecuritiesList/runcreatehbasetables.sh > /root/hdp_nifi_twitter_demo/logs/runcreatehbasetables.log

echo "Creating dictionary..."
/root/hdp_nifi_twitter_demo/dictionary/run_createdictionary.sh > /root/hdp_nifi_twitter_demo/logs/run_createdictionary.log

echo "Creating /tweets/staging HDFS dir"
sudo -u hdfs hadoop fs -rm -R /tweets
sudo -u hdfs hadoop fs -mkdir /tweets
sudo -u hdfs hadoop fs -chmod 777 /tweets
sudo -u hdfs hadoop fs -mkdir /tweets/staging
sudo -u hdfs hadoop fs -chmod 777 /tweets/staging

echo "Creating Hive table..."
hive -f /root/hdp_nifi_twitter_demo/twittertopology/twitter.sql > /root/hdp_nifi_twitter_demo/logs/create-hivetable.log

sudo -u hdfs hadoop fs -chmod 777 /tweets
sudo -u hdfs hadoop fs -chmod 777 /tweets/staging

echo "Setup complete. Logs available under /root/hdp_nifi_twitter_demo/logs"

echo "Run start-demo.sh to submit the Storm Twitter topology. Once submitted, start the Twitter producer via kafkaproducer/runkafkaproducer.sh"

