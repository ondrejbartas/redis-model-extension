# -*- encoding : utf-8 -*-
module RedisModelExtension
  module InstanceMethods

    #remove record form database
    def destroy!
      if exists?
        #destroy main object
        RedisModelExtension::Database.redis.del(redis_key) 
        destroy_aliases!
      end
    end

    # remove all aliases
    def destroy_aliases!
      #do it only if it is existing object!
      if redis_old_args
        redis_alias_config.each do |alias_name, fields|
          if self.class.valid_alias_key?(alias_name, redis_old_args) && self.class.alias_exists?(alias_name, redis_old_args)
            RedisModelExtension::Database.redis.del self.class.generate_alias_key(alias_name, redis_old_args)
          end
        end
        redis_dynamic_alias_config.each do |dynamic_alias_name, config|
          if self.class.valid_dynamic_key?(dynamic_alias_name, redis_old_args) && self.class.dynamic_exists?(dynamic_alias_name, redis_old_args)
            RedisModelExtension::Database.redis.del self.class.generate_dynamic_key(dynamic_alias_name, redis_old_args)
          end
        end
      end
    end
    
    # create aliases (create key value [STRING] key is alias redis key and value is redis key)
    def create_aliases
      main_key = redis_key
      redis_alias_config.each do |alias_name, fields|
        RedisModelExtension::Database.redis.set(redis_alias_key(alias_name), main_key) if valid_alias_key? alias_name
      end
      redis_dynamic_alias_config.each do |dynamic_alias_name, config|
        RedisModelExtension::Database.redis.set(redis_dynamic_key(dynamic_alias_name), main_key) if valid_dynamic_key? dynamic_alias_name
      end
    end
  
    # update multiple attrubutes at once
    def update args
      args.each do |key, value|
        method = "#{key}=".to_sym 
        if self.respond_to? method
          self.send(method, value)
        end
      end
    end

    # save method - save all attributes (fields) and create aliases
    def save
      # can be saved into redis?
      if valid?
        #autoicrement id
        self.send("id=", autoincrement_id) if redis_key_config.include?(:id) && !self.id?

        #generate key (possibly new)
        generated_key = redis_key        

        #take care about renaming saved hash in redis (if key changed)
        if redis_old_args 
          old_key = self.class.generate_key(redis_old_args)
          RedisModelExtension::Database.redis.rename(old_key, generated_key) if generated_key != old_key && RedisModelExtension::Database.redis.exists(old_key)
        end

        #ignore nil values for save 
        args = self.class.redis_save_fields_with_nil_conf ? to_arg : to_arg.reject{|k,v| v.nil?}

        #perform save to redis hash
        RedisModelExtension::Database.redis.hmset(generated_key, *args.inject([]){ |arr,kv| arr + [kv[0], value_to_redis(kv[0], kv[1])]})
        
        #destroy aliases
        destroy_aliases!
        create_aliases

        #after save make sure instance remember old key to know if it needs to be ranamed
        store_args
        return self
      else
        raise ArgumentError, @error.join(", ")
      end
    end
    
  end
end