package hellostorm;

import java.io.Serializable;
import java.util.Map;
import java.util.Objects;

import org.apache.log4j.Logger;

import twitter4j.HashtagEntity;
import twitter4j.Status;
import twitter4j.TwitterException;
import twitter4j.TwitterObjectFactory;
import backtype.storm.task.OutputCollector;
import backtype.storm.task.TopologyContext;
import backtype.storm.topology.IRichBolt;
import backtype.storm.topology.OutputFieldsDeclarer;
import backtype.storm.tuple.Fields;
import backtype.storm.tuple.Tuple;
import backtype.storm.tuple.Values;

public class TweetParserBolt implements IRichBolt {
	
	private static final long serialVersionUID = 1L;
	private static final Logger logger = Logger.getLogger(TweetParserBolt.class);
	
	private OutputCollector collector;
	private TweetParserOp op;
	private Response r;

	public TweetParserBolt() {
	}

	public void cleanup() {
		

	}

	public void execute(Tuple input) {
		String tweet = input.getString(0);
		r = op.parse(tweet);
		if(r!=null)
			collector.emit(input, new Values(r.getUserId(), r.getDisplayName(), r.getHashTag(), r.getTweet(), r.getCreated(), r.getLatitude(), r.getLongitude(), r.getLanguage(), r.getFullText()));
		
		collector.ack(input);
	}

	public void prepare(Map arg0, TopologyContext arg1, OutputCollector collector) {
		this.collector = collector;
		this.op = new TweetParserOp();

	}

	public void declareOutputFields(OutputFieldsDeclarer declarer) {
		declarer.declare(new Fields("userId", "displayname", "hashtag", "tweet", "created", "longitude", "latidude", "language", "fulltext"));

	}

	public Map<String, Object> getComponentConfiguration() {
		// TODO Auto-generated method stub
		return null;
	}
	
	
	public class TweetParserOp{
		
		
		public Response parse(String tweet){
			
			Response r = new Response();
			try {
				Status status = TwitterObjectFactory.createStatus(tweet);
				
				r.setUserId(Long.toString(status.getUser().getId()));
				r.setDisplayName(status.getUser().getScreenName().replace("\n", "").replace("\r", "").replace("|","").replace(",",""));
				
				StringBuilder tags = new StringBuilder();
				for (HashtagEntity h : status.getHashtagEntities()){
					tags.append(h.getText() + " ");
				}
				r.setHashTag(tags.toString());
				r.setTweet(status.getText().replace("\n", "").replace("\r", "").replace("|","").replace(",",""));
				r.setCreated(status.getCreatedAt().toString());
				if(status.getGeoLocation()!=null){
					r.setLongitude(Objects.toString(status.getGeoLocation().getLongitude(), "0"));
					r.setLatitude(Objects.toString(status.getGeoLocation().getLatitude(), "0"));
				}
				r.setLanguage(status.getLang());
				r.setFullText(status.toString().replace("\n", "").replace("\r", "").replace("|",""));
				
			} catch (Exception e) {
				logger.error(String.format("Error parsing tweet - this tweet will be skipped.\n %s", e.getMessage()));
				return null;
			}
			
			return r;
		}
		
		
	}
	
	public class Response{
		
		private String userId;
		private String displayName;
		private String hashTag;
		private String tweet;
		private String created;
		private String longitude = "0";
		private String latitude = "0";
		private String language;
		private String fullText;
		
		public String getUserId() {
			return userId;
		}
		public void setUserId(String userId) {
			this.userId = userId;
		}
		public String getDisplayName() {
			return displayName;
		}
		public void setDisplayName(String displayName) {
			this.displayName = displayName;
		}
		public String getHashTag() {
			return hashTag;
		}
		public void setHashTag(String hashTag) {
			this.hashTag = hashTag;
		}
		public String getTweet() {
			return tweet;
		}
		public void setTweet(String tweet) {
			this.tweet = tweet;
		}
		public String getCreated() {
			return created;
		}
		public void setCreated(String created) {
			this.created = created;
		}
		public String getLongitude() {
			return longitude;
		}
		public void setLongitude(String longitude) {
			this.longitude = longitude;
		}
		public String getLatitude() {
			return latitude;
		}
		public void setLatitude(String latitude) {
			this.latitude = latitude;
		}
		public String getLanguage() {
			return language;
		}
		public void setLanguage(String language) {
			this.language = language;
		}
		public String getFullText() {
			return fullText;
		}
		public void setFullText(String fullText) {
			this.fullText = fullText;
		}
		
		
	}

}

