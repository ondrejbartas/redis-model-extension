# -*- encoding : utf-8 -*-
module RedisModelExtension

  module ClassValidations

    # Validates if key by arguments is valid
    # (all needed fields are not nil!)
    def valid_key? args = {}
      #normalize input hash of arguments
      args = HashWithIndifferentAccess.new(args)

      redis_key_config.each do |key|
        return false unless valid_item_for_redis_key? args, key
      end
      return true
    end


    # Validates if key by alias name and arguments is valid
    # (all needed fields are not nil!)
    def valid_alias_key? alias_name, args = {}
      raise ArgumentError, "Unknown dynamic alias, use: #{redis_alias_config.keys.join(", ")}" unless redis_alias_config.has_key?(alias_name.to_sym)

      #normalize input hash of arguments
      args = HashWithIndifferentAccess.new(args)

      config = redis_alias_config[alias_name.to_sym]


      # use all specified keys
      config[:main_fields].each do |key|
        return false unless valid_item_for_redis_key? args, key
      end

      # is dynamic alias?
        if config[:order_field] && config[:args_field]
        #check if input arguments has order field
        if args.has_key?(config[:order_field]) && args[config[:order_field]] && args.has_key?(config[:args_field]) && args[config[:args_field]]
          #use filed order from defined field in args
          args[config[:order_field]].each do |key|
            return false unless valid_item_for_redis_key? args[config[:args_field]], key
          end
        else 
          return false
        end
      end

      return true
    end

    # validate one item of redis key
    def valid_item_for_redis_key? args, key
      (args.has_key?(key) && !args[key].nil?) || redis_fields_config[key] == :autoincrement
    end

    private 

    #look for bad cofiguration in redis key and raise argument error
    def validate_redis_key
      valid_fields = redis_fields_config.select{|k,v| v != :array && v != :hash  }.keys
      bad_fields = redis_key_config - valid_fields
      raise ArgumentError, "Sorry, but you cannot use as redis key [nonexisting | array | hash] fields: [#{bad_fields.join(",")}], availible are: #{valid_fields.join(", ")}" unless bad_fields.size == 0
    end
      

  end

  module Validations

    #pointer to validation
    def valid_key?
      self.class.valid_key? to_arg
    end

    #pointer to validation
    def valid_alias_key? alias_name
      self.class.valid_alias_key? alias_name, to_arg
    end
    
    def error
      self.errors
    end
  end
end