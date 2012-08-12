# -*- encoding : utf-8 -*-
module RedisModelExtension
  # == Config
  # set private methods for accessing & storing class configurations
  module ClassConfig

    #store informations about saving nil values
    def redis_save_fields_with_nil_conf
      @redis_save_fields_with_nil_conf.nil? ? @redis_save_fields_with_nil_conf = true : @redis_save_fields_with_nil_conf
    end

    #store informations about current class fields settings
    def redis_fields_config
      @redis_model_config ||= {}
    end

    #store informations about current class fields defaults settings
    def redis_fields_defaults_config
      @redis_model_defaults_config ||= {}
    end

    #store informations about current class redis key fields
    def redis_key_config
      @redis_key_config ||= []
    end

    #store informations about current class aliases settings
    def redis_alias_config
      @redis_alias_config ||= {}
    end

    #store informations about current class dynamic alias settings
    def redis_dynamic_alias_config
      @redis_dynamic_alias_config ||={}
    end

    private

    #store informations about all user defined fields settings
    def redis_user_field_config
      @redis_user_field_config ||= []
    end

  end

  # == Config
  # set private methods for accessing class configurations form instance
  module Config
    private 

    # pointer to class settings
    def redis_key_config
      self.class.redis_key_config
    end

    # pointer to class settings
    def redis_fields_config
      self.class.redis_fields_config
    end

    # pointer to class settings
    def redis_fields_defaults_config
      self.class.redis_fields_defaults_config
    end

    # pointer to class settings
    def redis_alias_config
      self.class.redis_alias_config
    end

    # pointer to class settings
    def redis_dynamic_alias_config
      self.class.redis_dynamic_alias_config
    end
  end
end