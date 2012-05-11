require 'tweetstream'
require 'oauth'
require 'thread'
require File.dirname(__FILE__)+'/../secret.rb'

class Twitter::JSONStream
  def receive_data(data)
    begin
      @parser << data
    rescue
      #puts data
      #puts "Caught a parsing error parsing the twitter stream"
      #puts "Since that would not be that constructive, I will kindly not exit now."
    end
  end
end

class TwitterHandler < Subscription
  field :flash_duration, type: Float, default: 0.5
  field :keyword, type: String

  handler_name "twitter"

  def initialize(attrs)
    super(attrs)
    insert_keyword
  end

  @@keywords = Hash.new
  TweetStream.configure do |config|
    config.consumer_key = TWITTER_CONSUMER_KEY
    config.consumer_secret = TWITTER_CONSUMER_SECRET
    config.oauth_token = TWITTER_ACCESS_TOKEN
    config.oauth_token_secret = TWITTER_ACCESS_SECRET
    config.auth_method = :oauth
    config.parser = :json_gem
  end
  @@client = nil
  @@client_lock = Mutex.new

  def insert_keyword()
    print "Twitter subscription: Beginning to watch for #{keyword}\n"
    @@keywords[keyword] = Proc.new do
      puts "Twitter event: flashing lamp #{destination.to_i}"
      @@com.flash_lamp(destination.to_i, flash_duration.to_f)
    end
    Thread.new do
      @@client_lock.synchronize {
        puts "Watching on twitter for #{@@keywords.keys}"
        if @@client
           @@client.close_connection
        else
          #EEEVIL RACE CONDITION WAITING TO EAT UR BRAINZ
          sleep 5.0
        end
        @@client = TweetStream::Client.new unless @@client
        @@client.on_error do |message|
          puts "Twitter stream error: #{message}"
        end.track(@@keywords.keys) do |status|
          @@keywords.each_pair do |keyword, handler|
            #handler.call if status.user.screen_name.downcase.include?(keyword.downcase) || status.text.downcase.include?(keyword.downcase)
          end
        end
      }
    end
  end
end
