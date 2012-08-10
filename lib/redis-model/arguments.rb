module RedisModel
  module InstanceMethods

    #Fixing some problems with saving nil into redis and clearing input arguments
    def clear_args(args)
      args.symbolize_keys!
      out_args = {}
      args.each do |key, value|
        if self.class.conf[:fields].keys.include?(key) #don't use arguments wich aren't specified in :fields 
          if value.nil? || value.to_s.size == 0 #change nil and zero length string into nil
            out_args[key] = nil 
          else
            out_args[key] = value
          end
        end
      end
      out_args
    end

    #take all arguments and send them out
    def to_arg
      redis_fields_config.inject({}) do |args, (key, type)|
        args[key] = self.send(key)
        args
      end
    end

    alias :args :to_arg
    
  end
end