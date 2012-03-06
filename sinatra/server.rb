#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json'
require File.dirname(__FILE__)+'/communicator.rb'
require File.dirname(__FILE__)+'/jsonrpc.rb'

enable :lock
outcom = Communicator.new("/dev/arduino1")
json_rpc_if = JSONRPCInterface.new()

json_rpc_if.register("set_lamp", outcom.method("set_lamp"))
json_rpc_if.register("get_lamp", outcom.method("get_lamp"))
json_rpc_if.register("set_lamps", outcom.method("set_lamps"))
json_rpc_if.register("get_lamps", outcom.method("get_lamps"))
json_rpc_if.register("set_meter", outcom.method("set_meter"))

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
  '{state: 0}'
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


post '/jsonrpc' do
	request.body.rewind
	json_rpc_if.handle_request(request.body.read)
end
