require 'net/http'

class HTTPGrepHandler < Subscription
  field :url,           type: String
  field :regex,         type: String
  field :poll_interval, type: Float
  after_initialize :start_polling

  handler_name "http-egrep"

  def start_polling()
    super(args)
    puts "HTTP-egrep subscription: Beginning to poll #{@url} for #{@regex} every #{@poll_interval} seconds"
    Thread.new do
      while true
        poll
        sleep @poll_interval
      end
    end
  end

  def poll()
    uri = URI(url)
    str = Net::HTTP.get(uri)
    if Regexp.compile(regex) =~ str
      @@com.set_lamp(@destination, 1);
    else
      @@com.set_lamp(@destination, 0);
    end
  end
end
