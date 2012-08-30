# -*- encoding : utf-8 -*-
module RedisModelExtension

  module ClassCreate
    
    # create instance and save it
    def create args = {}
      instance = self.new(args)
      instance.save
      return instance
    end

  end

  module SaveDestroy

    # save method - save all attributes (fields) and create aliases
    def save
      perform = lambda do
        # can be saved into redis?
        if valid?

          #autoicrement id
          self.send("id=", increment_id) if redis_key_config.include?(:id) && !self.id?

          #generate key (possibly new)
          generated_key = redis_key        

          #take care about renaming saved hash in redis (if key changed)
          if redis_old_keys[:key] && redis_old_keys[:key] !=  generated_key && RedisModelExtension::Database.redis.exists(redis_old_keys[:key])
            RedisModelExtension::Database.redis.rename(redis_old_keys[:key], generated_key)
          end

          #ignore nil values for save 
          args = self.class.redis_save_fields_with_nil_conf ? to_arg : to_arg.reject{|k,v| v.nil?}

          #perform save to redis hash
          RedisModelExtension::Database.redis.hmset(generated_key, *args.inject([]){ |arr,kv| arr + [kv[0], value_to_redis(kv[0], kv[1])]})
          
          # destroy aliases
          destroy_aliases!
          create_aliases

          #after save make sure instance remember old key to know if it needs to be ranamed
          store_keys
        end
      end

      run_callbacks :save do
        unless exists?
          run_callbacks :create do
            perform.()
          end
        else
          perform.()
        end
      end
      unless errors.any?
        return self
      else
        return false
      end
    end

    # create aliases (create key value [STRING] key is alias redis key and value is redis key)
    def create_aliases
      main_key = redis_key
      redis_alias_config.each do |alias_name, fields|
        RedisModelExtension::Database.redis.sadd(redis_alias_key(alias_name), main_key) if valid_alias_key? alias_name
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

    #remove record form database
    def destroy!
      if exists?
        run_callbacks :destroy do
          #destroy main object
          RedisModelExtension::Database.redis.del(redis_key) 
          destroy_aliases!
        end
      end
    end

    alias :destroy :destroy!

    # remove all aliases
    def destroy_aliases!
      #do it only if it is existing object!
      if redis_old_keys[:aliases].size > 0
        redis_old_keys[:aliases].each do |alias_key|
          RedisModelExtension::Database.redis.srem alias_key, redis_old_keys[:key]
          #delete alias with 0 keys
          RedisModelExtension::Database.redis.del(alias_key) if RedisModelExtension::Database.redis.scard(alias_key).to_i == 0
        end
      end
    end
    
  end
end