# -*- encoding : utf-8 -*-
require 'pp'
require 'yaml'
require 'redis'
require 'active_support'
require 'active_support/inflector'
require 'active_support/inflector/inflections'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/indifferent_access'
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
      
  end
    
  module InstanceMethods
    
  end
end

#require all additional modules
require 'redis-model/initialize'
require 'redis-model/old_initialize'
require 'redis-model/value_transform'
require 'redis-model/redis_key'
require 'redis-model/get_find'
require 'redis-model/validation'
require 'redis-model/arguments'
require 'redis-model/save_destroy'
