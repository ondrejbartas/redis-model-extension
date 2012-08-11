# -*- encoding : utf-8 -*-
require 'pp'
require 'yaml'
require 'json'
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

module RedisModelExtension

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
require 'redis-model-extension/config'
require 'redis-model-extension/initialize'
require 'redis-model-extension/old_initialize'
require 'redis-model-extension/value_transform'
require 'redis-model-extension/redis_key'
require 'redis-model-extension/get_find'
require 'redis-model-extension/validation'
require 'redis-model-extension/attributes'
require 'redis-model-extension/save_destroy'
require 'redis-model-extension/changed_redis_key'

#bad naming in past, will be removed
require 'redis-model'
