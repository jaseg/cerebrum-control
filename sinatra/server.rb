#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'json'
require File.dirname(__FILE__)+'/communicator.rb'
require File.dirname(__FILE__)+'/jsonrpc.rb'
require File.dirname(__FILE__)+'/subscription.rb'
require File.dirname(__FILE__)+'/ledpcap.rb'

set :public_folder, File.dirname(__FILE__) + '/static'

enable :lock
outcom = Communicator.new("/dev/arduino0")
subs = Array.new
json_rpc_if = JSONRPCInterface.new
lpc = LEDPcap.new(32769, 26, 0.5, outcom)

json_rpc_if.register("set_lamp", outcom.method("set_lamp"))
json_rpc_if.register("get_lamp", outcom.method("get_lamp"))
json_rpc_if.register("set_lamps", outcom.method("set_lamps"))
json_rpc_if.register("get_lamps", outcom.method("get_lamps"))
json_rpc_if.register("set_meter", outcom.method("set_meter"))

get '/' do
  send_file "static/index.html"
end

get '/lamps' do
  outcom.get_lamps
end

post '/lamps' do
  outcom.set_lamps(params[:buffer].to_i)
end

get '/lamps/:id' do |lamp|
  outcom.get_lamp(lamp.to_i)
end

post '/lamps/:id' do |lamp|
  outcom.set_lamp(lamp.to_i, params[:state].to_i)
end

get '/switches/:id' do |switch|
  '{"state": 0}'
end

get '/switches/:id/handlers' do |switch|
  '[]'
end

post '/switches/:id/handlers' do |switch|
end

delete '/switches/:id/handlers/:handler' do |switch, handler|
end

post '/meters/:id' do |meter|
  outcom.set_meter(meter, params[:value])
end


post '/subscriptions' do
  request.body.rewind
  begin
    body = JSON.parse request.body.read
    begin
      body["com"] = outcom
      sub = Subscription.handlers[body["type"]].new(body)
      subs << sub
      print "Added #{body["type"]} subscription #{body["description"]} on lamp #{body["destination"]}\n"
      return '{"success":42}'
    rescue ArgumentError
      return '{"error": "Parameter missing"}'
    end
  rescue
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
  puts "Getting subscriptions: #{subs}"
  #Sorry for that mess, standard to_json wouldn't work were (it did not return)
  '['+subs.map {|sub|
    "{\"description\":\"#{sub.description}\",\"destination\":\"#{sub.destination}\",\"type\":\"#{sub.type}\",\"matches\":[#{sub.class.params.map{|param|"\"#{param}\":\"#{sub.instance_variable_get '@'+param}\""}.join(",")}]"
  }.join(',')+']'
end

delete '/subscription/:id' do |id|
  subs.delete_if{|src| src._id.to_s == id}.to_json
end


post '/jsonrpc' do
  request.body.rewind
  json_rpc_if.handle_request(request.body.read)
end
