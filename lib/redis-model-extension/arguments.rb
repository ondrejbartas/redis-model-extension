# -*- encoding : utf-8 -*-
module RedisModelExtension
  module InstanceMethods

    #take all arguments and send them out
    def to_arg
      redis_fields_config.inject({}) do |args, (key, type)|
        args[key] = self.send(key)
        args
      end
    end

    alias :args :to_arg
    
    #put arguments into json
    def to_json
      to_arg.to_json
    end
    
  end
end