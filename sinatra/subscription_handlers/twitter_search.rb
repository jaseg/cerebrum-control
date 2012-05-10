require 'tweetstream'
require 'oauth'
require 'thread'
require File.dirname(__FILE__)+'/../secret.rb'

class Twitter::JSONStream
  def receive_data(data)
    begin
      @parser << data
    rescue
      puts data
      puts "Caught a parsing error parsing the twitter stream"
    end
  end
end

class TwitterHandler < Subscription
  field :flash_duration,    type: Integer, default: 0.5
  after_initialize  :insert_keyword

  handler_name "twitter"

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
        @@client.close_connection if @@client
        @@client = TweetStream::Client.new unless @@client
        @@client.on_error do |message|
          puts "Twitter stream error: #{message}"
        end.track(@@keywords.keys) do |status|
          @@keywords.each_pair do |keyword, handler|
            handler.call if status.user.screen_name.downcase.include?(keyword.downcase) || status.text.downcase.include?(keyword.downcase)
          end
        end
      }
    end
  end
end
