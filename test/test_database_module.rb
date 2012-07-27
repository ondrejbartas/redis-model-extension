# -*- encoding : utf-8 -*-
require 'helper'
class DatabaseModuleTest < Test::Unit::TestCase
  context "DatabaseModule" do
    setup do
      #cleare previously assigned redis instance
      RedisModelExtension::Database.redis = nil
    end

    should "be initialized directly" do
      assert_nothing_raised do
        RedisModelExtension::Database.redis = Redis.new(host: "127.0.0.1", port: 6379, db: 0)
        RedisModelExtension::Database.redis.info
      end
      assert RedisModelExtension::Database.redis.is_a? Redis
    end

    should "be initialized from config" do
      assert_nothing_raised do
        RedisModelExtension::Database.redis.info
      end
      assert RedisModelExtension::Database.redis.is_a? Redis
    end
  end
end
