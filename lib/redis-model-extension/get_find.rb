# -*- encoding : utf-8 -*-
module RedisModelExtension
  module ClassMethods

    ######################################
    #  FIND METHODS
    ######################################

    #Wrapper around find to get all instances
    def all
      self.find({})
    end

    #Find method for searching in redis
    def find(args = {})
      #normalize input hash of arguments
      args = HashWithIndifferentAccess.new(args)

      out = []
      klass = self.name.constantize
      
      #is key specified directly? -> no needs of looking for other keys! -> faster
      if klass.valid_key?(args)
        if klass.exists?(args)
          out << klass.new_by_key(klass.generate_key(args)) 
        end
      else
        RedisModelExtension::Database.redis.keys(klass.generate_key(args)).each do |key|
          out << klass.new_by_key(key) 
        end
      end
      out
    end

    #Find method for searching in redis
    def find_by_alias(alias_name, args = {})
      #check if asked alias exists
      raise ArgumentError, "Unknown alias '#{alias_name}', use: #{redis_alias_config.keys.join(", ")}" unless redis_alias_config.has_key?(alias_name.to_sym)
      
      #normalize input hash of arguments
      args = HashWithIndifferentAccess.new(args)

      out = []
      klass = self.name.constantize
      #is key specified directly? -> no needs of looking for other keys! -> faster
      if klass.valid_alias_key?(alias_name, args)
        out << klass.get_by_alias(alias_name, args) if klass.alias_exists?(alias_name, args)
      else
        RedisModelExtension::Database.redis.keys(klass.generate_alias_key(alias_name, args)).each do |key|
          out << klass.get_by_alias_key(key)
        end
      end
      out
    end

    #Find method for searching in redis
    def find_by_dynamic(dynamic_alias_name, args = {})
      #check if asked dynamic alias exists
      raise ArgumentError, "Unknown dynamic alias: '#{dynamic_alias_name}', use: #{redis_dynamic_alias_config.keys.join(", ")} " unless redis_dynamic_alias_config.has_key?(dynamic_alias_name.to_sym)

      #normalize input hash of arguments
      args = HashWithIndifferentAccess.new(args)

      out = []
      klass = self.name.constantize
      #is key specified directly? -> no needs of looking for other keys! -> faster
      if klass.valid_dynamic_key?(dynamic_alias_name, args)
        out << klass.get_by_dynamic(dynamic_alias_name, args) if klass.dynamic_exists?(dynamic_alias_name, args)
      else
        RedisModelExtension::Database.redis.keys(klass.generate_dynamic_key(dynamic_alias_name, args)).each do |key|
          out << klass.get_by_dynamic_key(key)
        end
      end
      out
    end

    ######################################
    #  GET BY ARGUMENTS
    ######################################

    #fastest method to get object from redis by getting it by arguments
    def get(args = {})
      #normalize input hash of arguments
      args = HashWithIndifferentAccess.new(args)

      klass = self.name.constantize
      if klass.valid_key?(args) && klass.exists?(args)
        klass.new_by_key(klass.generate_key(args)) 
      else
        nil
      end
    end

    ######################################
    #  GET BY REDIS KEYS
    ######################################

    #fastest method to get object from redis by getting it by alias and arguments
    def get_by_alias(alias_name, args = {})
      #check if asked alias exists
      raise ArgumentError, "Unknown alias '#{alias_name}', use: #{redis_alias_config.keys.join(", ")}" unless redis_alias_config.has_key?(alias_name.to_sym)
      #normalize input hash of arguments
      args = HashWithIndifferentAccess.new(args)

      klass = self.name.constantize
      if klass.valid_alias_key?(alias_name, args) && klass.alias_exists?(alias_name, args)
        key = RedisModelExtension::Database.redis.get(klass.generate_alias_key(alias_name, args))
        return klass.new_by_key(key) if RedisModelExtension::Database.redis.exists(key)
      end
      nil
    end    

    #fastest method to get object from redis by getting it by dynamic alias and arguments
    def get_by_dynamic(dynamic_alias_name, args = {})
      #check if asked dynamic alias exists
      raise ArgumentError, "Unknown dynamic alias: '#{dynamic_alias_name}', use: #{redis_dynamic_alias_config.keys.join(", ")} " unless redis_dynamic_alias_config.has_key?(dynamic_alias_name.to_sym)
      
      #normalize input hash of arguments
      args = HashWithIndifferentAccess.new(args)

      klass = self.name.constantize
      if klass.valid_dynamic_key?(dynamic_alias_name, args) && klass.dynamic_exists?(dynamic_alias_name, args)
        key = RedisModelExtension::Database.redis.get(klass.generate_dynamic_key(dynamic_alias_name, args))
        return klass.new_by_key(key) if RedisModelExtension::Database.redis.exists(key)
      end
      nil
    end    


    ######################################
    #  GET BY REDIS KEYS
    ######################################

    #if you know redis key and would like to get object
    def get_by_redis_key(redis_key)
      if redis_key.is_a?(String) && RedisModelExtension::Database.redis.exists(redis_key)
        klass = self.name.constantize
        klass.new_by_key(redis_key)
      else
        nil
      end
    end 

    #fastest method to get object from redis by getting it by alias and arguments
    def get_by_alias_key(alias_key)
      klass = self.name.constantize
      if RedisModelExtension::Database.redis.exists(alias_key)
        key = RedisModelExtension::Database.redis.get(alias_key)
        return klass.new_by_key(key) if RedisModelExtension::Database.redis.exists(key)
      end
      nil
    end 
    alias :get_by_dynamic_key :get_by_alias_key


    ######################################
    #  CREATE NEW OBJECT BY HASH VALUES
    ######################################
        
    # read all data from redis and create new instance (used for Find & Get method)
    def new_by_key(key)
      args = HashWithIndifferentAccess.new(RedisModelExtension::Database.redis.hgetall(key))

      new_instance = self.name.constantize.new(args)
      new_instance.store_args

      return new_instance
    end

  end
end