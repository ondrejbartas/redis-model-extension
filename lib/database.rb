# -*- encoding : utf-8 -*-
#Wrapper for redis connection
#============================
#Creates only one connection to redis per application in first time it needs to work with redis
module Database

  def self.config
    if File.exists?('config/redis_config.yml')
      YAML.load_file('config/redis_config.yml')[ENV['RACK_ENV'] || 'development'].symbolize_keys
    else
      FileUtils.mkdir_p('config') unless File.exists?('config')
      FileUtils.cp(File.join(File.dirname(__FILE__),"/config/redis_config.yml.example"), 'config/redis_config.yml.example')
      raise ArgumentError, "Redis configuration file does not exists -> 'config/redis_config.yml', please provide it! I have created example file in config directory..."
    end
  end
  
  def self.redis
    @redis ||= Redis.new(Database.config)
  end

end