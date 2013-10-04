# -*- encoding : utf-8 -*-
#Wrapper for redis connection
#============================
#Creates only one connection to redis per application in first time it needs to work with redis
module RedisModelExtension
  module Database

    def self.config
      if File.exists?('config/redis_config.yml')
        YAML.load_file('config/redis_config.yml')[ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'].symbolize_keys
      else
        FileUtils.mkdir_p('config') unless File.exists?('config')
        FileUtils.cp(File.join(File.dirname(__FILE__),"../config/redis_config.yml.example"), 'config/redis_config.yml.example')
        raise ArgumentError, "Redis configuration file does not exists -> 'config/redis_config.yml', please provide it! I have created example file in config directory..."
      end
    end
    
    def self.redis_config= conf
      raise ArgumentError, "Argument must be hash {:host => '..', :port => 6379, :db => 0 }" unless conf.has_key?(:host) && conf.has_key?(:port) && conf.has_key?(:db)
      @redis_config = conf
    end

    def self.redis= redis
      if redis.is_a?(Redis) #valid redis instance
        Thread.current[:redis_model_extension] = redis  
      elsif redis.nil? #remove redis instance for changing connection or using in next call configs
        Thread.current[:redis_model_extension] = nil
      else #else you assigned something wrong
        raise ArgumentError, "You have to assign Redis instance!"
      end
    end

    def self.redis
      #if redis is already defined
      return Thread.current[:redis_model_extension] if Thread.current[:redis_model_extension]
      #if you provided redis config
      return Thread.current[:redis_model_extension] = Redis.new(@redis_config) if @redis_config
      #if you provided yml config
      return Thread.current[:redis_model_extension] = Redis.new(Database.config)
    end

  end
end