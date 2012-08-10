module RedisModel
  module InstanceMethods

    def value_to_redis name, value
      if redis_fields_config.has_key?(name)
        value_transform value, redis_fields_config[name]
      else
        value
      end
    end

    def value_transform value, type
      return nil if value.nil? || value.to_s.size == 0
      case type
      when :integer then value.to_i
      when :string then value.to_s
      when :float then value.to_f
      when :bool then value.to_s
      when :symbol then value.to_s
      when :array then value.to_json
      when :hash then value.to_json
      else value
      end
    end

    def value_parse value, type
      return nil if value.nil? || value.to_s.size == 0
      case type
      when :integer then value.to_i
      when :string then value.to_s
      when :float then value.to_f
      when :bool then value.to_s.to_bool
      when :symbol then value.to_s.to_sym
      when :array then value.is_a?(String) ? JSON.parse(value) : value
      when :hash then value.is_a?(String) ? JSON.parse(value) : value
      else value
      end
    end

  end
end