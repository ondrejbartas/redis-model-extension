# -*- encoding : utf-8 -*-
module RedisModelExtension
  module ClassMethods

    # Generates redis key for storing object
    # * will produce something like: your_class:key:field_value1:field_value2... 
    # (depending on your redis_key setting)
      out = "#{self.name.to_s.underscore.to_sym}:key"
      redis_key_config.each do |key|
        if args.has_key?(key) && !args[key].nil?
          out += ":#{args[key]}"
        else
          out += ":*"
        end
      end
      out
    end
    
    # Generates redis key for storing indexes for aliases
    # * will produce something like: your_class:alias:name_of_your_alias:field_value1:field_value2... 
    # (depending on your redis_alias setting)
      out = "#{self.name.to_s.underscore.to_sym}:alias:#{alias_name}"
      redis_alias_config[alias_name.to_sym].each do |key|
        if args.has_key?(key) && !args[key].nil?
          out += ":#{args[key]}"
        else
          out += ":*"
        end
      end
      out
    end
    
    # Validates if key by arguments is valid
    # (all needed fields are not nil!)
      full_key = true
      redis_key_config.each do |key|
        full_key = false if !args.has_key?(key) || args[key].nil?
      end
      full_key
    end

    # Validates if key by alias name and arguments is valid
    # (all needed fields are not nil!)
      full_key = true
      redis_alias_config[alias_name.to_sym].each do |key|
        full_key = false if !args.has_key?(key) || args[key].nil?
      end
      full_key
    end

    # Check if key by arguments exists in db
    def exists? args = {}
      RedisModelExtension::Database.redis.exists(self.name.constantize.generate_key(args))
    end

    #Check if key by alias name and arguments exists in db
    def alias_exists? alias_name, args = {}
      RedisModelExtension::Database.redis.exists(self.name.constantize.generate_alias_key(alias_name, args))
    end
  end
    
  module InstanceMethods

    # get redis key for instance
    def redis_key
      self.class.generate_key(to_arg)
    end
    
    # get redis key for instance alias
    def redis_alias_key alias_name 
      self.class.generate_alias_key(alias_name, to_arg)
    end
  
    # if this record exists in database
    def exists?
      RedisModelExtension::Database.redis.exists(self.class.generate_key(to_arg))
    end

  end
end