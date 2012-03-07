require 'net/http'

SubscriptionManager.register_source_handler "grep" do |src|
  uri = URI(src.url)
  str = Net::HTTP.get(uri)
  Regexp.compile(src.content) =~ str
end
