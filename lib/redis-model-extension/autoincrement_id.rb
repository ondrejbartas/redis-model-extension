# -*- encoding : utf-8 -*-
module RedisModelExtension

  # == Class Autoincrement Id
  # get last id
  # generate autoincrement key
  module ClassAutoincrementId

    # get last id from redis
    def get_last_id
      Database.redis.get generate_autoincrement_key
    end

    #generate autoincrement key
    def generate_autoincrement_key
      "#{self.name.to_s.underscore.to_sym}:autoincrement_id"
    end

  end

  # == Autoincrement Id
  # increment id
  module AutoincrementId

    private

    # get auto incremented id from redis
    def increment_id
      Database.redis.incr self.class.generate_autoincrement_key
    end

    # get last id from redis
    def get_last_id
      self.class.get_last_id
    end

  end
end