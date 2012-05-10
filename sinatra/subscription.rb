require 'mongo'
require 'mongoid'

subdb = Mongo::Connection.new.db("cerebrum")
subcoll = subdb["subscriptions"]

class Subscription
  include Mongoid::Callbacks
  include Mongoid::Dirty
  include Mongoid::Fields
  field :description,   type: String
  field :destination,   type: Integer
  after_initialize :store_to_db
  @@handlers = Hash.new()

  def self.com=(com)
    @@com = com
  end

  def self.load_from_db ()
    subcoll.find.each do |doc|
     doc._id 
    end
  end

  def store_to_db ()
    subcoll.insert(self.attributes)
  end

  def self.handlers
    @@handlers
  end

  def self.type
    @type
  end

  def self.handler_name(name)
    @@handlers[name] = self
    @type = name
  end

  def self.params()
    fields.delete_if{|fieldname,value|fieldname =~ /^_/ or ["description", "destination", "com"].include? fieldname}
  end
end

Dir.glob(File.dirname(__FILE__)+"/subscription_handlers/*.rb").each{|f| require f}
