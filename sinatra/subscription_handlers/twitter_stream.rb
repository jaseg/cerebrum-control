require 'tweetstream'
require 'oauth'
require File.dirname(__FILE__)+'/../secret.rb'

class TwitterHandler < Subscription
#  include Mongoid::Document
#  field :keyword,           type: String
#  field :flash_duration,    type: Integer
  attr_accessor :keyword
  attr_accessor :flash_duration

  def initialize (args)
    super(args)
    @flash_duration = 0.5
    Thread.new do
      print "Twitter subscription: Beginning to watch for #{@keyword}\n"
      TweetStream::Client.new.track(@keyword) do |status|
        print "Twitter event: @#{status.user.screen_name}: #{status.text}\n"
        @com.flash_lamp(@destination, @flash_duration)
      end
    end
  end

  TweetStream.configure do |config|
    config.consumer_key = TWITTER_CONSUMER_KEY
    config.consumer_secret = TWITTER_CONSUMER_SECRET
    config.oauth_token = TWITTER_ACCESS_TOKEN
    config.oauth_token_secret = TWITTER_ACCESS_SECRET
    config.auth_method = :oauth
  end
  @@handlers["twitter"] = self
end
