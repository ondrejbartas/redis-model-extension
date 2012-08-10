module RedisModel
  module ClassMethods
    #Wrapper around find to get all instances
    def all
      self.find({})
    end

    #Find method for searching in redis
    def find(args = {})
      args.symbolize_keys!
      out = []
      klass = self.name.constantize
      
      #is key specified directly? -> no needs of looking for other keys! -> faster
      if klass.valid_key?(args)
        if klass.exists?(args)
          data_args = RedisModelExtension::Database.redis.hgetall(klass.generate_key(args))
          out << klass.new(args.merge(data_args).merge({:old_args => data_args})) 
        end
      else
        RedisModelExtension::Database.redis.keys(klass.generate_key(args)).each do |key|
          data_args = RedisModelExtension::Database.redis.hgetall(key)
          out << klass.new(args.merge(data_args).merge({:old_args => data_args}))
        end
      end
      out
    end

    #Find method for searching in redis
    def find_by_alias(alias_name, args = {})
      args.symbolize_keys!
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

    #fastest method to get object from redis by getting it by arguments
    def get(args = {})
      args.symbolize_keys!
      klass = self.name.constantize
      if klass.valid_key?(args) && klass.exists?(args)
        data_args = RedisModelExtension::Database.redis.hgetall(klass.generate_key(args))
        klass.new(args.merge(data_args).merge({:old_args => data_args})) 
      else
        nil
      end
    end

    #if you know redis key and would like to get object
    def get_by_redis_key(redis_key)
      if redis_key.is_a?(String) && RedisModelExtension::Database.redis.exists(redis_key)
        unless redis_key.include?("*")
          data_args = RedisModelExtension::Database.redis.hgetall(redis_key)
          klass = self.name.constantize
          klass.new(data_args.merge({:old_args => data_args})) 
        else
          raise ArgumentError, "RedisKey for method get_by_redis_key can not contains '*'"
        end
      else
        nil
      end
    end 

    #fastest method to get object from redis by getting it by alias and arguments
    def get_by_alias(alias_name, args = {})
      args.symbolize_keys!
      klass = self.name.constantize
      if klass.valid_alias_key?(alias_name, args) && klass.alias_exists?(alias_name, args)
        key = RedisModelExtension::Database.redis.get(klass.generate_alias_key(alias_name, args))
        if RedisModelExtension::Database.redis.exists(key)
          data_args = RedisModelExtension::Database.redis.hgetall(key)
          klass.new(args.merge(data_args).merge({:old_args => data_args})) 
        else
          nil
        end
      else
        nil
      end
    end    

    #fastest method to get object from redis by getting it by alias and arguments
    def get_by_alias_key(alias_key)
      klass = self.name.constantize
      if RedisModelExtension::Database.redis.exists(alias_key)
        key = RedisModelExtension::Database.redis.get(alias_key)
        if RedisModelExtension::Database.redis.exists(key)
          old_args = RedisModelExtension::Database.redis.hgetall(key)
          klass.new(old_args.merge({:old_args => old_args}))
        else
          nil
        end
      else
        nil
      end
    end 
     
  end
end