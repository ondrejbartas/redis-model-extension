# -*- encoding : utf-8 -*-
module RedisModelExtension

  # == Old Initialize
  # port for old initialize method to new structure
  module ClassOldInitialize
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
    # old method to initialize redis model extenstion
    # Usage:
    #  REDIS_MODEL_CONF = {
    #   :fields => { 
    #     :integer => :to_i,
    #     :boolean => :to_bool,
    #     :string => :to_s,
    #     :symbol => :to_sym,
    #    }, 
    #    :required => [:integer, :string],
    #    :redis_key => [:string, :symbol],
    #    :redis_aliases => {
    #      :token => [:symbol]
    #    },
    #    # (default is true) if true all nil values will not be saved into redis,
    #    # there should be problem when you want to set some value to nil and same
    #    # it will not be saved (use false to prevent this)
    #    :reject_nil_values => false 
    # }
    # include RedisModel
    # initialize_redis_model_methods REDIS_MODEL_CONF
    def initialize_redis_model_methods conf
      puts "WARNING: This initilization method is deprecated and will be removed in future! \n Please read documentation how to change your model to use new initialization methods"

      remove_redis_autoincrement_key

      @conf = {:reject_nil_values => true}.merge(conf)
      #take all fields and make methods for them
      conf[:fields].each do |name, action|
        redis_fields_config[name] = TYPE_TRANSLATIONS.invert[action]
        redis_fields_defaults_config[name] = nil

        # define getter method for field
        define_method "#{name}" do
          value_get name
        end
        
        # define setter method for field
        define_method "#{name}=" do |new_value|
          value_set name, new_value
        end
        
        # define exists? method for field
        define_method "#{name}?" do
          value_get(name) && !value_get(name).blank? ? true : false
        end
      end
      
      # save nil values?
      redis_save_fields_with_nil false if !conf.has_key?(:reject_nil_values) || conf[:reject_nil_values] == true

      # save into class config about redis key
      @redis_key_config = conf[:redis_key]

      #validate presence of all fields in key
      @required_config = (@redis_key_config | conf[:required]) 
      (@redis_key_config | conf[:required]).each do |field|
        validates field, :presence => :true
      end

      # save into class config about redis keys
      @redis_alias_config = {}
      conf[:redis_aliases].each do |key, fields|
        @redis_alias_config[key] = { 
          main_fields: fields,
          order_field: nil,
          args_field: nil,
        }
      end
    end
    
    # get config hash
    def conf
      fields = {}
      redis_fields_config.each do |key, type|
        fields[key] = TYPE_TRANSLATIONS[type] if TYPE_TRANSLATIONS.has_key?(type)
      end
      {
        fields: fields,
        required: @required_config.sort,
        redis_key: redis_key_config,
        redis_aliases: redis_alias_config.inject({}){|o,(k,v)| o[k] = v[:main_fields]; o},
        reject_nil_values: !redis_save_fields_with_nil_conf,
      }
    end
   
  end

end
