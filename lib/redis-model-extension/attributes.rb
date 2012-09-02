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
    alias :attributes :to_arg

    #put arguments into json
    def to_json
      to_arg.to_json
    end

    private

    # get value from instance variable
    def value_get name
      instance_variable_get(:"@#{name}")
    end
    alias :attribute :value_get

    # set value into instance variable
    def value_set name, value
      instance_variable_set(:"@#{name}", value_parse(value, redis_fields_defaults_config[name]))
    end
    alias :attribute= :value_set

    def attribute?(name)
      value_get(name) && !value_get(name).blank? ? true : false
    end

  end
end
