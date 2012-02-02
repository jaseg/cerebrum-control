#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json'
require 'communicator'

enable :lock
outcom = Communicator.new("/dev/ttyACM0")

get '/lamps' do
  outcom.get_lamps
end

post '/lamps' do
  outcom.set_lamps (params[:buffer])
end

get '/lamps/:id' do |lamp|
  outcom.get_lamp (lamp)
end

post '/lamps/:id' do |lamp|
  outcom.set_lamp (lamp, params[:state])
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
  outcom.set_meter (meter, params[:value])
end
