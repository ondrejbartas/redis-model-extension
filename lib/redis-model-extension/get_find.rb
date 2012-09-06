# -*- encoding : utf-8 -*-
module RedisModelExtension

  # == Get & Find
  # * Model.all => Array of all instances
  # * Model.find(1) => Array of one instance with id 1
  # * Model.get(1) => Array of one instance with id 1
  # * Model.find( id: 1 ) => Array of one instance with id 1
  # * Model.find( field: "test" ) => Array of all instances with field == test [field must be in redis key]
  module ClassGetFind

    ######################################
    #  FIND METHODS
    ######################################

    #Find method for searching in redis
    # * args (Integer) - search by id
    # * args (Hash) - search by arguments in redis_key
    def find(args = {})
      # when argument is integer - search by id
      args = { id: args } if args.is_a?(Integer)
      #normalize input hash of arguments
      args = HashWithIndifferentAccess.new(args)

      out = []
      klass = self.name.constantize
      search_key = klass.generate_key(args)
      #is key specified directly? -> no needs of looking for other keys! -> faster
      unless search_key =~ /\*/
        out << klass.new_by_key(search_key) if klass.exists?(args)
      else
        RedisModelExtension::Database.redis.keys(search_key).each do |key|
          out << klass.new_by_key(key)
        end
      end
      out
    end
    alias :all :find

    #Find method for searching in redis
    def find_by_alias(alias_name, args = {})
      #check if asked dynamic alias exists
      raise ArgumentError, "Unknown dynamic alias: '#{alias_name}', use: #{redis_alias_config.keys.join(", ")} " unless redis_alias_config.has_key?(alias_name.to_sym)

      #normalize input hash of arguments
      args = HashWithIndifferentAccess.new(args)

      out = []
      klass = self.name.constantize
      search_key = klass.generate_alias_key(alias_name, args)
      #is key specified directly? -> no needs of looking for other keys! -> faster
      unless search_key =~ /\*/
        out = klass.get_by_alias(alias_name, args) if klass.alias_exists?(alias_name, args)
      else
        RedisModelExtension::Database.redis.keys(search_key).each do |key|
          out << klass.get_by_alias_key(key)
        end
      end
      out.flatten
    end

    ######################################
    #  GET BY ARGUMENTS
    ######################################

    #fastest method to get object from redis by getting it by arguments
    # * args (Integer) - search by id
    # * args (Hash) - search by arguments in redis_key
    def get(args = {})
      # when argument is integer - search by id
      args = { id: args } if args.is_a?(Integer)

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

    #fastest method to get object from redis by getting it by dynamic alias and arguments
    def get_by_alias(alias_name, args = {})
      #check if asked dynamic alias exists
      raise ArgumentError, "Unknown dynamic alias: '#{alias_name}', use: #{redis_alias_config.keys.join(", ")} " unless redis_alias_config.has_key?(alias_name.to_sym)

      #normalize input hash of arguments
      args = HashWithIndifferentAccess.new(args)

      klass = self.name.constantize
      if klass.valid_alias_key?(alias_name, args) && klass.alias_exists?(alias_name, args)
        out = []
        RedisModelExtension::Database.redis.smembers(klass.generate_alias_key(alias_name, args)).each do |key|
          item = klass.new_by_key(key)
          out << item if item
        end
        return out
      end
      nil
    end


    ######################################
    #  GET BY REDIS KEYS
    ######################################

    #if you know redis key and would like to get object
    def get_by_redis_key(redis_key)
      if redis_key.is_a?(String)
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
        out = []
        RedisModelExtension::Database.redis.smembers(alias_key).each do |key|
          item = klass.new_by_key(key)
          out << item if item
        end
        return out
      end
      nil
    end

    ######################################
    #  CREATE NEW OBJECT BY HASH VALUES
    ######################################

    # read all data from redis and create new instance (used for Find & Get method)
    def new_by_key(key)
      args = RedisModelExtension::Database.redis.hgetall(key)
      return nil unless args && args.any?
      args.symbolize_keys!

      new_instance = new(args)
      new_instance.store_keys

      return new_instance
    end

  end
end
