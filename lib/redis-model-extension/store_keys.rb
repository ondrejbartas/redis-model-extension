# -*- encoding : utf-8 -*-
module RedisModelExtension
  module StoreKeys

    # store old arguments, need's to be called in find/get initialization
    # will remember old arguments and remember redis keys
    # if some fileds in redis key will change, then do rename
    # without this you can end up with old and new saved object!
    def store_keys
      store_redis_keys
    end

    private 

    # set old arguments
    def store_redis_keys
      args = to_arg
      #store main key
      redis_old_keys[:key] = self.class.generate_key(args) #store main key

      #store alias keys
      redis_old_keys[:aliases] = []
      redis_alias_config.each do |alias_name, fields|
        redis_old_keys[:aliases] << redis_alias_key(alias_name) if valid_alias_key? alias_name
      end
    end

    # get old arguments
    def redis_old_keys
      @redis_old_keys ||= {:key => nil, :aliases => []}
    end

  end
end