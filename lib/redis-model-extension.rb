# -*- encoding : utf-8 -*-
require 'pp'
require 'yaml'
require 'json'
require 'redis'
require 'active_model'
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
  extend ActiveSupport::Concern
  #include all needed modules directly into main class
  def self.included(base) 
    base.class_eval do
      extend ClassInitialize
      extend ClassOldInitialize
      extend ClassConfig
      extend ClassGetFind
      extend ClassRedisKey  
      extend ClassCreate
      extend ClassValidations
      extend ClassAutoincrementId

      include Initialize
      include ActiveModelIntegration
      include Attributes
      include AutoincrementId
      include RedisKey
      include StoreOldArguments
      include Config
      include SaveDestroy
      include Validations
      include ValueTransform
    end
  end

  module ActiveModelIntegration
    def self.included(base)
      base.class_eval do
        include ActiveModel::AttributeMethods
        include ActiveModel::Validations
        include ActiveModel::Naming
        include ActiveModel::Conversion

        extend  ActiveModel::Callbacks
        define_model_callbacks :save, :destroy, :create
      end
    end
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
require 'redis-model-extension/store_old_arguments'
require 'redis-model-extension/autoincrement_id'
#bad naming in past, will be removed
require 'redis-model'
