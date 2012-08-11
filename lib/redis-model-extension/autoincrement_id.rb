# -*- encoding : utf-8 -*-
module RedisModelExtension

  module InstanceMethods

    private

    # get auto incremented id from redis
    def autoincrement_id
      Database.redis.incr self.class.autoincrement_key
    end

  end
end