# -*- encoding : utf-8 -*-
module RedisModelExtension
  module ClassMethods


    #add new field which will be saved into redis
    # * name - name of your variable
    # * type - type of your variable (:integer, :float, :string, :array, :hash)
    # * default - default value of your variable
    def redis_field name, type, default = nil

      redis_fields_config[name] = type
      redis_fields_defaults_config[name] = default

      #get value
      define_method name do
        value_get name  
      end

      #assign new value
      define_method "#{name}=" do |new_value|
        value_set name, new_value
      end

      #does value exists?
      define_method "#{name}?" do 
        value_get(name) && !value_get(name).blank? ? true : false
      end

      redis_save_fields_with_nil true
    end

    #set redis key which will be used for storing model
    def redis_key *fields
      @redis_key_config = fields

      #automaticaly add all fields from key to validation
      #diable invalid keys to be saved
      @redis_validation_config ||= []
      @redis_validation_config |= fields
    end

    #set fields which will must be valid before save
    def redis_validate *fields
      @redis_validation_config ||= []
      @redis_validation_config |= fields
    end

    def redis_alias name, fields
      @redis_alias_config ||= {}
      @redis_alias_config[name] = fields
    end

    #store informations about saving nil values
    def redis_save_fields_with_nil store
      @redis_save_fields_with_nil_conf = store
    end

  end

  module InstanceMethods

    # initialize instance    
    def initialize(args={})
      args = HashWithIndifferentAccess.new(args)
      # look for fields in input hash
      redis_fields_config.each do |key, type|
        #input hash has known field
        if args.has_key?(key) 
          value_set key, value_parse(args[key], type)
        else #there is no value set default valued
          value_set key, redis_fields_defaults_config[key]
        end
      end

      return self
    end

  end
end