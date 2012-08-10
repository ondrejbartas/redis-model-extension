# -*- encoding : utf-8 -*-
require 'pp'
require 'yaml'
require 'redis'
require 'active_support'
require 'active_support/inflector'
require 'active_support/inflector/inflections'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/class/inheritable_attributes'
require 'string_to_bool'
require 'database'


module RedisModel

  attr_accessor :args, :error, :old_args, :conf

  #include all needed modules directly into main class
  def self.included(base) 
    base.send :extend,  ClassMethods         
    base.send :include, InstanceMethods  
  end

  module ClassMethods
    
    def initialize_redis_model_methods conf
      @conf = {:reject_nil_values => true}.merge(conf)
      #take all fields and make methods for them
      conf[:fields].each do |attr, action|
        define_method "#{attr}" do
          if self.args[attr] || self.args[attr] == false #== false is a fi for boolean variable
            self.args[attr].to_s.send(action)
          else
            nil
          end
        end
        
        define_method "#{attr}=" do |item|
          self.args[attr] = item
        end
        
        define_method "#{attr}?" do
          !self.args[attr].nil?
        end
      end  
    end
    
    def conf
      @conf
    end
   
  end
    
  module InstanceMethods
    
    def initialize(args={})
      args.symbolize_keys!
      #if old_args is specified, don't usi it in args hash
      if args[:old_args] && args[:old_args].size > 0 
        self.old_args = args.delete(:old_args).symbolize_keys
      end
      self.args = clear_args(args)

      return self
    end

  end
end

#require all additional modules
require 'redis-model/redis_key'
require 'redis-model/get_find'
require 'redis-model/validation'
require 'redis-model/arguments'
require 'redis-model/save_destroy'
