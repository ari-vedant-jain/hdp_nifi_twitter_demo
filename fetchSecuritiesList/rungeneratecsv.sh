
echo "Compiling jar..."
cd /root/hdp_nifi_twitter_demo/fetchSecuritiesList
rm -f fetchsecurities.jar
rm -rf classes
mkdir classes
javac  -d classes *.java
jar -cvf fetchsecurities.jar -C classes/ .
export CLASSPATH=fetchsecurities.jar
java example.producer.FetchSecuritiesList

