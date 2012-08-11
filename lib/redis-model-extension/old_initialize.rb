module RedisModelExtension
  TYPE_TRANSLATIONS = { 
    :integer => :to_i, 
    :string => :to_s, 
    :bool => :to_bool, 
    :symbol => :to_sym, 
    :array => :to_array, 
    :hash => :to_hash, 
    :time => :to_time, 
    :date => :to_date 
  }

  module ClassMethods

    def initialize_redis_model_methods conf
      @conf = {:reject_nil_values => true}.merge(conf)
      #take all fields and make methods for them
      conf[:fields].each do |name, action|
        redis_fields_config[name] = RedisModelExtension::TYPE_TRANSLATIONS.invert[action]
        redis_fields_defaults_config[name] = nil

        define_method "#{name}" do
          value_get name
        end
        
        define_method "#{name}=" do |new_value|
          value_set name, new_value
        end
        
        define_method "#{name}?" do
          value_get(name) && !value_get(name).blank? ? true : false
        end
      end
      
      redis_save_fields_with_nil false if !conf.has_key?(:reject_nil_values) || conf[:reject_nil_values] == true
      @redis_key_config = conf[:redis_key]
      @redis_validation_config = conf[:required]
      @redis_alias_config = conf[:redis_aliases]
    end
    
    def conf
      fields = {}
      redis_fields_config.each do |key, type|
        fields[key] = RedisModelExtension::TYPE_TRANSLATIONS[type] if RedisModelExtension::TYPE_TRANSLATIONS.has_key?(type)
      end
      {
        fields: fields,
        required: redis_validation_config,
        redis_key: redis_key_config,
        redis_aliases: redis_alias_config,
        reject_nil_values: !redis_save_fields_with_nil_conf,
      }
    end
   
  end

end