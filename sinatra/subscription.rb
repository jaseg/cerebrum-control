require 'mongoid'

class Subscription
#  include Mongoid::Document
#  field :description,   type: String
#  field :destination,   type: Integer
  attr_accessor :description
  attr_accessor :destination
  attr_reader   :com

  def initialize (args)
    args.each do |key,val|
      instance_variable_set "@#{key}", val unless val.nil?
    end if args.is_a? Hash
  end
  @@handlers = Hash.new()
  def self.handlers ()
    @@handlers
  end
end

Dir.glob(File.dirname(__FILE__)+"/subscription_handlers/*.rb").each{|f| require f}
