# -*- encoding : utf-8 -*-
module RedisModelExtension
  module StoreOldArguments

    # store old arguments, need's to be called in find/get initialization
    # will remember old arguments and remember redis keys
    # if some fileds in redis key will change, then do rename
    # without this you can end up with old and new saved object!
    def store_args
      set_redis_old_args to_arg
    end

    private 

    # set old arguments
    def set_redis_old_args old_args
      @redis_old_args = old_args
    end

    # get old arguments
    def redis_old_args
      @redis_old_args ||= {}
    end

  end
end