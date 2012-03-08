require 'net/http'

class HTTPGrepHandler < Subscription
#  include Mongoid::Document
#  field :url,       type: String
#  field :regex,     type: String
  attr_accessor :url
  attr_accessor :regex

  def poll ()
    uri = URI(url)
    str = Net::HTTP.get(uri)
    if Regexp.compile(regex) =~ str
      @com.set_lamp(@destination, 1);
    else
      @com.set_lamp(@destination, 0);
    end
  end

  @@handlers["http-egrep"] = self
end
