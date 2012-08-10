module RedisModel
  module InstanceMethods

    #remove record form database
    def destroy!
      if exists?
        #destroy main object
        RedisModelExtension::Database.redis.del(redis_key) 
        destroy_aliases!
      end
    end

    #remove all aliases
    def destroy_aliases!
      #do it only if it is existing object!
      if self.old_args
        self.class.conf[:redis_aliases].each do |alias_name, fields|
          if self.class.valid_alias_key?(alias_name, self.old_args) && self.class.alias_exists?(alias_name, self.old_args)
            RedisModelExtension::Database.redis.del(self.class.generate_alias_key(alias_name, self.old_args)) 
          end
        end
      end
    end
    
    #Method for creating aliases
    def create_aliases
      main_key = redis_key
      self.class.conf[:redis_aliases].each do |alias_name, fields|
        RedisModelExtension::Database.redis.set(self.class.generate_alias_key(alias_name, self.args), main_key) if self.class.valid_alias_key?(alias_name, self.args)
      end
    end
  
    #update multiple attrubutes at once
    def update args
      args.each do |key, value|
        method = "#{key}=".to_sym 
        if self.respond_to? method
          self.send(method, value)
        end
      end
    end

    #save method
    def save
      if valid?
        #generate key (possibly new)
        generated_key = redis_key
        RedisModelExtension::Database.redis.rename(self.class.generate_key(self.old_args), generated_key) if self.old_args && generated_key != self.class.generate_key(self.old_args) && RedisModelExtension::Database.redis.exists(self.class.generate_key(self.old_args))
        args = self.class.conf[:reject_nil_values] ? self.args.reject{|k,v| v.nil?} : self.args
        RedisModelExtension::Database.redis.hmset(generated_key, *args.inject([]){ |arr,kv| arr + [kv[0], kv[1].to_s]})
        
        #destroy aliases
        destroy_aliases!
        create_aliases
        #after save make new_key -> old_key
        self.old_args = self.args.clone
        return self
      else
        raise ArgumentError, @error.join(", ")
      end
    end
    
  end
end