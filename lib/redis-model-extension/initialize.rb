# -*- encoding : utf-8 -*-
module RedisModelExtension

  # == Class Initialize
  # redis_field - defines fields to be stored into redis
  # redis_alias - defines aliases for finding models 
  # redis_key - defines wich fields will be in redis key
  # redis_key_normalize - normalization of redis key (downcase, transliterate)
  # redis_save_fields_with_nil - enable/disable save of nil fields into redis
  module ClassInitialize
    VALID_NORMALIZATIONS = [:downcase, :transliterate]

    #add new field which will be saved into redis
    # * name - name of your variable
    # * type - type of your variable (:integer, :float, :string, :array, :hash)
    # * (default) - default value of your variable
    def redis_field name, type, default = nil
      redis_user_field_config << name

      # remember field to save into redis
      redis_fields_config[name] = type
      # remember field default value
      redis_fields_defaults_config[name] = default

      # get value
      define_method name do
        value_get name  
      end

      # assign new value
      define_method "#{name}=" do |new_value|
        value_set name, new_value
      end

      # value exists? (not nil and not blank?)
      define_method "#{name}?" do 
        value_get(name) && !value_get(name).blank? ? true : false
      end
    end

    def set_redis_autoincrement_key
      @redis_key_config ||= [:id]

      # get value
      define_method :id do
        value_get :id 
      end

      # value exists? (not nil and not blank?)
      define_method "id?" do 
        value_get(:id) && !value_get(:id).blank? ? true : false
      end

      # set value
      define_method "id=" do |new_value|
        value_set :id, new_value
      end
      private :id= #set it as private

      redis_fields_config[:id] = :autoincrement
    end

    def remove_redis_autoincrement_key
      # remove get value
      remove_method :id

      # remove value exists? (not nil and not blank?)
      remove_method "id?"

      # remove set value
      remove_method "id="

      redis_fields_config.delete(:id)
    end


    # set redis key which will be used for storing model
    def redis_key *fields
      @redis_key_config = fields.flatten
      
      validate_redis_key
      
      #own specification of redis key - delete autoincrement
      remove_redis_autoincrement_key unless redis_user_field_config.include?(:id) || @redis_key_config.include?(:id)

      # automaticaly add all fields from key to validation
      # if any of fields in redis key is nil
      # then prevent to save it
      @redis_key_config.each do |field|
        validates field, :presence => :true if field != :id
      end
    end
    
    # set redis model to normalize redis keys
    def redis_key_normalize *metrics
      @redis_key_normalize_conf ||= []
      metrics.each do |metric|
        raise ArgumentError, "Please provide valid normalization: #{VALID_NORMALIZATIONS.join(", ")}" unless VALID_NORMALIZATIONS.include?(metric)
        @redis_key_normalize_conf << metric
      end
    end

    # store informations about redis aliases
    def redis_alias name, main_fields, name_of_field_for_order = nil, name_of_field_for_args = nil
      #set fields if they are not allready set!
      if name_of_field_for_order && name_of_field_for_args
        redis_field name_of_field_for_order, :array, [] unless redis_fields_config.has_key?(name_of_field_for_order)
        redis_field name_of_field_for_args, :hash, {} unless redis_fields_config.has_key?(name_of_field_for_args)
      end

      @redis_alias_config ||= {}
      #add specification of dynamic alias
      @redis_alias_config[name] = { 
        main_fields: main_fields,
        order_field: name_of_field_for_order,
        args_field: name_of_field_for_args,
      }

      #create alias methods for find and get (find_by_name, get_by_name)
      create_class_alias_method(name)
    end

    # store informations about saving nil values
    def redis_save_fields_with_nil store
      @redis_save_fields_with_nil_conf = store
    end

    # store informations about redis key normalization
    def redis_key_normalize_conf
      @redis_key_normalize_conf ||= []
    end

    private
    
    def create_class_alias_method(name)
      self.class.instance_eval do
        define_method("find_by_#{name}") do |args|
          find_by_alias(name, args)
        end
        define_method("get_by_#{name}") do |args|
          get_by_alias(name, args)
        end
      end
    end

  end

  module Initialize
    extend ActiveSupport::Concern

    included do
      redis_save_fields_with_nil true
      set_redis_autoincrement_key
    end

    # initialize instance    
    def initialize(args={})
      args = HashWithIndifferentAccess.new(args)
      # look for fields in input hash
      redis_fields_config.each do |key, type|
        # disable to set nonexisting ID!
        raise ArgumentError, "You cannot specify #{key} (it is auto incremented)" if args[key] && type == :autoincrement && get_last_id.to_i < args[key].to_i

        # input hash has known field
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
