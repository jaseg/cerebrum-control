#!/usr/bin/env ruby

require 'sinatra'
require 'json'
require File.dirname(__FILE__)+'/jsonrpc.rb'
require File.dirname(__FILE__)+'/subscription.rb'

set :public_folder, File.dirname(__FILE__) + '/static'

enable :lock
outcom = JSONRPCClient.new("10.0.1.27", 4567, "/jsonrpc")
Subscription.com = outcom
Subscription.load_from_db

get '/' do
  send_file "static/index.html"
end

get '/switches/:id/handlers' do |switch|
  '[]'
end

post '/switches/:id/handlers' do |switch|
end

delete '/switches/:id/handlers/:handler' do |switch, handler|
end

post '/subscriptions' do
  request.body.rewind
  begin
    body = JSON.parse request.body.read
    begin
      puts Subscription.handlers[body["type"]]
      sub = Subscription.handlers[body["type"]].create!(body)
      puts outcom
      sub.com = outcom
      subs << sub
      print "Added #{body["type"]} subscription #{body["description"]} on lamp #{body["destination"]}\n"
      return '{"success":42}'
    rescue ArgumentError
      puts $!
      return '{"error": "Parameter missing"}'
    end
  rescue
    puts $!
    return '{"error": "Expecting JSON"}'
  end
end

get '/subscription/type/:type/params' do
  return '[]' unless Subscription.handlers[params[:type]]
  return Subscription.handlers[params[:type]].params.to_json
end

get '/subscription/types' do
  return Subscription.handlers.keys.to_json
end

get '/subscriptions' do
  #Sorry for that mess, standard to_json wouldn't work were (it did not return)
  #'['+subs.map {|sub|
  #  "{\"description\":\"#{sub.description}\",\"destination\":\"#{sub.destination}\",\"type\":\"#{sub.type}\",\"matches\":{#{sub.class.params.map{|param|"\"#{param}\":\"#{sub.instance_variable_get '@'+param}\""}.join(",")}}}"
  #}.join(',')+']'
  sf = subs.map{|sub|
    formatted = Hash.new
    formatted["description"] = sub.description
    formatted["destination"] = sub.destination
    formatted["type"] = sub.class.type
    formatted["matches"] = Hash.new
    sub.class.params.each_key{|param| formatted["matches"][param] = sub.send param}
    formatted
  }
  [200, {"Content-Type" => "text/json"}, sf.to_json]
end

delete '/subscription/:id' do |id|
  subs.delete_if{|src| src._id.to_s == id}.to_json
end
