module RedisModelExtension
  module ClassMethods

    # read all data from redis and create new instance
    def new_by_key(key)
      args = HashWithIndifferentAccess.new(RedisModelExtension::Database.redis.hgetall(key))

      new_instance = self.name.constantize.new(args)
      new_instance.store_args

      return new_instance
    end

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

    #store informations about saving nil values
    def redis_save_fields_with_nil_conf
      @redis_save_fields_with_nil_conf.nil? ? @redis_save_fields_with_nil_conf = true : @redis_save_fields_with_nil_conf
    end

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

    #store informations about current class aliases settings
    def redis_alias_config
      @redis_alias_config ||= {}
    end

    #store informations about current class fields validation
    def redis_validation_config
      @redis_validation_config ||= []
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

    # store old arguments, need's to be called in find/get initialization
    # will remember old arguments and remember redis keys
    # if some fileds in redis key will change, then do rename
    # without this you can end up with old and new saved object!
    def store_args
      set_redis_old_args @redis_args.clone      
    end

    private 

      # get value from instance variable
      def value_get name
        if @redis_args && @redis_args.has_key?(name.to_sym)
          @redis_args[name.to_sym]
        else
          nil
        end
      end

      # set value into instance variable
      def value_set name, value
        @redis_args ||= {}
        @redis_args[name.to_sym] = value
      end

      # get old arguments
      def set_redis_old_args old_args
        @redis_old_args = old_args
      end

      # get old arguments
      def redis_old_args
        @redis_old_args ||= {}
      end

      # pointer to class settings
      def redis_fields_config
        self.class.redis_fields_config
      end

      # pointer to class settings
      def redis_fields_defaults_config
        self.class.redis_fields_defaults_config
      end

      # pointer to class settings
      def redis_alias_config
        self.class.redis_alias_config
      end

      # pointer to class settings
      def redis_validation_config
        self.class.redis_validation_config
      end
  end
end