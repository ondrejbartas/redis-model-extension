# -*- encoding : utf-8 -*-
require 'helper'
class RedisKeyTest < Test::Unit::TestCase
  context "Redis key" do
    setup do
      RedisModelExtension::Database.redis.flushdb
      @time = Time.now
      @args = {
        "integer" => 12345, 
        :string => "foo", 
        :symbol => :bar, 
        :boolean => true, 
        :array => [1,2,3], 
        :hash => {"foo"=>"bar", "test" => 2}, 
        :time => @time, 
        :date => Date.today
      }
      @test_model = TestRedisModel.new(@args)
    end 

    should "generate right search key" do
      @test_model.string = nil
      assert_equal @test_model.redis_key, "#{TestRedisModel.to_s.underscore}:key:*"
      assert_equal TestRedisModel.generate_key(@args.merge({:string => nil})), "#{TestRedisModel.to_s.underscore}:key:*"
    end  

         
    should "generate right key" do
      assert_equal @test_model.redis_key, "#{TestRedisModel.to_s.underscore}:key:foo"
      assert_equal TestRedisModel.generate_key(@args), "#{TestRedisModel.to_s.underscore}:key:foo"
    end  

    should "generate right key alias" do
      assert_equal @test_model.redis_alias_key(:token), "#{TestRedisModel.to_s.underscore}:alias:token:bar"
      assert_equal TestRedisModel.generate_alias_key(:token, @args), "#{TestRedisModel.to_s.underscore}:alias:token:bar"
    end  
  end
end