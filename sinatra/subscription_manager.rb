require 'mongoid'

class SubscriptionManager
  def initialize (com)
    @com = com
    @sources = Array.new
    Thread.new do
      while true
        poll_sources
        sleep 1.0
      end
    end
  end

  def poll_sources ()
    @sources.each do |src|
      if src.next_poll < Time.now
        lamp_state = @@source_handlers[src.handler].call(src)
        printf "Polling source #{src.description}: #{lamp_state == 0 || !!lamp_state}\n"
        @com.set_lamp(src.destination, lamp_state)
        src.polled
      end
    end
  end

  def << (src)
    @sources << src
  end

  @@source_handlers = Hash.new

  def self.register_source_handler (name, &block)
    @@source_handlers[name] = block
  end

  Dir.glob(File.dirname(__FILE__)+"/source_handlers/*.rb").each{|f| require f}
end

class Source
  include Mongoid::Document
  embedded_in :subscriptionmanager
  field :description,   type: String
  field :destination,   type: Integer
  field :url,           type: String
  field :handler,       type: String
  field :poll_interval, type: Integer
  field :entry,         type: String #The "adress" inside of whatever is found at the given url. Could contain a regex, xpath expression, plain string etc.
  field :content,       type: String #Most likely to be a regex, the content that should light the lamp

  attr_accessor :last_polled

  def polled ()
    @last_polled = Time.now
  end

  def next_poll ()
    if @last_polled
      @last_polled + poll_interval
    else
      Time.now
    end
  end
end
