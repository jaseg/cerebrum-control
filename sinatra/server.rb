#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json'
require 'communicator'

get '/lamps/:id' do |lamp|

end

post '/lamps/:id' do |lamp|
    
end


get '/switches/:id' do |switch|

end


get '/switches/:id/handlers' do |switch|

end

post '/switches/:id/handlers' do |switch|

end

delete '/switches/:id/handlers/:handler' do |switch, handler|

end

get '/meters/:id' do |meter|

end

post '/meters/:id' do |meter|

end
