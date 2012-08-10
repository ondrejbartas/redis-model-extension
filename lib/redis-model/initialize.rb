module RedisModel
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
      define_method "#{name}?" do |new_value|
        value_get(name) && !value_get(name).empty? ? true : false
      end

    end

    #set redis key which will be used for storing model
    def redis_key *fields
      redis_key_config = fields

      #automaticaly add all fields from key to validation
      #diable invalid keys to be saved
      redis_validation_config |= fields
    end

    #set fields which will must be valid before save
    def redis_validate *fields
      redis_validation_config |= fields
    end

    #Private config methods!
    private
      #store informations about current class fields settings
      def redis_fields_config
        @redis_model_config ||= {}
      end

      #store informations about current class fields defaults settings
      def redis_fields_defaults_config
        @redis_model_defaults_config ||= {}
      end

      #store informations about current class redis key fields
      def redis_key_config
        @redis_key_config ||= []
      end

      #store informations about current class fields validation
      def redis_validation_config
        @redis_validation_config ||= []
      end
  end

  module InstanceMethods
    
    private 

      def value_get name
        if @redis_args && @redis_args.has_key?(name.to_sym)
          @redis_args[name.to_sym]
        else
          nil
        end
      end

      def value_set name, value
        @redis_args ||= {}
        @redis_args[name.to_sym] = value
      end
  end
end