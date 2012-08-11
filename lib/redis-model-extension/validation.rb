# -*- encoding : utf-8 -*-
module RedisModelExtension

  module ClassMethods

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
      raise ArgumentError, "Unknown alias, use: #{redis_alias_config.keys.join(", ")}" unless redis_alias_config.has_key?(alias_name.to_sym)

      #normalize input hash of arguments
      args = HashWithIndifferentAccess.new(args)

      redis_alias_config[alias_name.to_sym].each do |key|
        return false unless valid_item_for_redis_key? args, key
      end
      return true
    end


    # Validates if key by alias name and arguments is valid
    # (all needed fields are not nil!)
    def valid_dynamic_key? dynamic_alias_name, args = {}
      raise ArgumentError, "Unknown dynamic alias, use: #{redis_dynamic_alias_config.keys.join(", ")}" unless redis_dynamic_alias_config.has_key?(dynamic_alias_name.to_sym)

      #normalize input hash of arguments
      args = HashWithIndifferentAccess.new(args)

      config = redis_dynamic_alias_config[dynamic_alias_name.to_sym]


      # use all specified keys
      config[:main_fields].each do |key|
        return false unless valid_item_for_redis_key? args, key
      end

      #check if input arguments has order field
      if args.has_key?(config[:order_field]) && args[config[:order_field]] && args.has_key?(config[:args_field]) && args[config[:args_field]]
        #use filed order from defined field in args
        args[config[:order_field]].each do |key|
          return false unless valid_item_for_redis_key? args[config[:args_field]], key
        end
      else 
        return false
      end
      return true
    end

    # validate one item of redis key
    def valid_item_for_redis_key? args, key
      args.has_key?(key) && !args[key].nil?
    end

  end

  module InstanceMethods

    #pointer to validation
    def valid_key?
      self.class.valid_key? to_arg
    end

    #pointer to validation
    def valid_alias_key? alias_name
      self.class.valid_alias_key? alias_name, to_arg
    end

    #pointer to validation
    def valid_dynamic_key? dynamic_alias_name
      self.class.valid_dynamic_key? dynamic_alias_name, to_arg
    end

    # validates required attributes
    def valid?
      @error ||= []
      redis_validation_config.each do |key|
        @error.push("Required #{key}") unless self.send("#{key}?")
      end
      @error.size == 0
    end

    #return error from validation
    def error
      @error ||= []
    end
    
    #always forgotting which one to use :)
    alias :errors :error    

  end
end