module RedisModel
  module ClassMethods
    
    #Generates redis key for storing object
    def generate_key(args = {})
      out = "#{self.name.to_s.underscore.to_sym}:key"
      @conf[:redis_key].each do |key|
        if args.has_key?(key)
          out += ":#{args[key]}"
        else
          out += ":*"
        end
      end
      out
    end
    
    #Generates redis key for storing indexes for aliases
    def generate_alias_key(alias_name, args = {})
      out = "#{self.name.to_s.underscore.to_sym}:alias:#{alias_name}"
      @conf[:redis_aliases][alias_name.to_sym].each do |key|
        if args.has_key?(key)
          out += ":#{args[key]}"
        else
          out += ":*"
        end
      end
      out
    end
    
    #Validates if key by arguments is valid
    def valid_key?(args = {})
      full_key = true
      @conf[:redis_key].each do |key|
        full_key = false if !args.has_key?(key) || args[key].nil?
      end
      full_key
    end

    #Validates if key by alias name and arguments is valid
    def valid_alias_key?(alias_name, args = {})
      full_key = true
      @conf[:redis_aliases][alias_name.to_sym].each do |key|
        full_key = false if !args.has_key?(key) || args[key].nil?
      end
      full_key
    end

    #Check if key by arguments exists in db
    def exists?(args = {})
      RedisModelExtension::Database.redis.exists(self.name.constantize.generate_key(args))
    end

    #Check if key by alias name and arguments exists in db
    def alias_exists?(alias_name, args = {})
      RedisModelExtension::Database.redis.exists(self.name.constantize.generate_alias_key(alias_name, args))
    end
  end
    
  module InstanceMethods

    #get redis key for instance
    def redis_key
      self.class.generate_key(self.args)
    end
    
    #get redis key for instance alias
    def redis_alias_key(alias_name)
      self.class.generate_alias_key(alias_name, self.args)
    end
  
    #if this record exists in database
    def exists?
      RedisModelExtension::Database.redis.exists(self.class.generate_key(self.args))
    end

  end
end