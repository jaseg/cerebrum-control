require 'mongo'
require 'mongoid'

class Subscription
  include ActiveModel::MassAssignmentSecurity
  include Mongoid::Threaded::Lifecycle
  include Mongoid::Attributes
  include Mongoid::Callbacks
  include Mongoid::Dirty
  include Mongoid::Fields
  include Mongoid::Relations
  include Mongoid::NestedAttributes
  field :description, type: String
  field :destination, type: Integer
  @@handlers = Hash.new()

  def initialize(attrs)
    @attributes ||= {}
    assign_attributes(attrs)
    store_to_db
  end

  def self.com=(com)
    @@com = com
  end

  def new? ()
    false
  end

  def self.subcoll=(subcoll)
    @@subcoll=subcoll
  end

  def self.load_from_db ()
    subs = []
    @@subcoll.find.each do |doc|
      #puts doc
      subs << @@handlers[doc["type"]].new(doc)
    end
    subs
  end

  def store_to_db ()
    @@subcoll.insert(self.attributes)
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
    fields.delete_if{|item| item =~ /^_/ or ["description", "destination", "com"].include? item}
  end
end

Dir.glob(File.dirname(__FILE__)+"/subscription_handlers/*.rb").each{|f| require f}
