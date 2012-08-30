# -*- encoding : utf-8 -*-
require 'pp'
require 'yaml'
require 'json'
require 'redis'
require 'hashr'
require 'active_model'
require 'active_support'
require 'active_support/inflector'
require 'active_support/inflector/inflections'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/blank'
require 'string_to_bool'
require 'database'

module RedisModelExtension
  extend ActiveSupport::Concern

  #include all needed modules directly into main class
  included do
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
    include StoreKeys
    include Config
    include SaveDestroy
    include Validations
    include ValueTransform
  end

  module ActiveModelIntegration
    extend ActiveSupport::Concern

    included do
      include ActiveModel::AttributeMethods
      include ActiveModel::Validations
      include ActiveModel::Naming
      include ActiveModel::Conversion

      extend  ActiveModel::Callbacks
      define_model_callbacks :save, :destroy, :create
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
require 'redis-model-extension/store_keys'
require 'redis-model-extension/autoincrement_id'
#bad naming in past, will be removed
require 'redis-model'
