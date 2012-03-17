require 'net/http'

class HTTPGrepHandler < Subscription
#  include Mongoid::Document
#  field :url,       type: String
#  field :regex,     type: String
  attr_accessor :url
  attr_accessor :regex

  def initialize(args)
    super(args)
    puts "http-egrep subscription initalized"
    raise ArgumentError.new "Missing required Parameters" unless @url and @regex
  end

  def poll ()
    uri = URI(url)
    str = Net::HTTP.get(uri)
    if Regexp.compile(regex) =~ str
      @com.set_lamp(@destination, 1);
    else
      @com.set_lamp(@destination, 0);
    end
  end

  def self.params ()
    ["url", "regex"]
  end

  def type ()
    "http-egrep"
  end
  @@handlers["http-egrep"] = self
end
