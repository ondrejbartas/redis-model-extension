# -*- encoding : utf-8 -*-
module RedisModelExtension

  # == Attribues
  # modul for easier getting all attributes
  # also for setting ang getting value instance variable
  module Attributes

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
    

    private 

    # get value from instance variable
    def value_get name
      if @redis_args && @redis_args.has_key?(name.to_sym)
        @redis_args[name.to_sym]
      else
        nil
      end
    end

    # set value into instance variable
    def value_set name, value
      @redis_args ||= {}
      @redis_args[name.to_sym] = value
    end

  end
end