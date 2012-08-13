# -*- encoding : utf-8 -*-
require 'helper'
class GetFindTest < Test::Unit::TestCase
  context "Get & Find" do
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
        :date => Date.today,
        :float => 12.32
      }
      @test_model = TestRedisModel.new(@args)
      @test_model.save
    end 
 
     context "main object" do

      should "be getted by redis_key" do
        @getted_model = TestRedisModel.get_by_redis_key(@test_model.redis_key)
        assert_equal @getted_model.integer, @test_model.integer
        assert_equal @getted_model.string, @test_model.string
        assert_equal @getted_model.symbol, @test_model.symbol
        assert_equal @getted_model.boolean, @test_model.boolean
      end

      should "return nil on triyng to get model by redis key without all valid variables (or nonexisting)" do
        @test_model.string = nil
        assert_nil TestRedisModel.get_by_redis_key(@test_model.redis_key)
      end

      should "be find by all" do
        @getted_models = TestRedisModel.all
        assert_equal @getted_models.size, 1, "Should be only one" 
      end

      should "be find by args" do
        @getted_models = TestRedisModel.find(:string => @args[:string])
        assert_equal @getted_models.size, 1, "Should be only one" 
      end

      should "be find by args zero" do
        @getted_models = TestRedisModel.find(:string => "nonexisting string")
        assert_equal @getted_models, [], "Should be empty array" 
      end

    end

    context "alias" do
      should "exists" do
        assert @test_model.alias_exists?(:token)
      end

      should "be getted by alias" do
        @getted_model = TestRedisModel.get_by_alias(:token, @args)
        assert_equal @getted_model.integer, @test_model.integer
        assert_equal @getted_model.string, @test_model.string
        assert_equal @getted_model.symbol, @test_model.symbol
        assert_equal @getted_model.boolean, @test_model.boolean
      end

      should "be find by alias" do
        @getted_models = TestRedisModel.find_by_alias(:token, :symbol => :bar)
        assert_equal @getted_models.size, 1, "Should be only one with alias" 
        @getted_model = @getted_models.first
        assert_equal @getted_model.integer, @test_model.integer
        assert_equal @getted_model.string, @test_model.string
        assert_equal @getted_model.symbol, @test_model.symbol
        assert_equal @getted_model.boolean, @test_model.boolean
      end

      should "be find by find_by_alias_name" do
        @getted_models = TestRedisModel.find_by_token(:symbol => :bar)
        assert_equal @getted_models.size, 1, "Should be only one with alias" 
        @getted_model = @getted_models.first
        assert_equal @getted_model.integer, @test_model.integer
      end
    
      should "be find all by alias" do
        @getted_models = TestRedisModel.find_by_alias(:token ,{})
        assert_equal @getted_models.size, 1, "Should be only one with alias" 
        @getted_model = @getted_models.first
        assert_equal @getted_model.integer, @test_model.integer
        assert_equal @getted_model.string, @test_model.string
        assert_equal @getted_model.symbol, @test_model.symbol
        assert_equal @getted_model.boolean, @test_model.boolean
      end

      should "be find all by find_by_name_of_alais" do
        @getted_models = TestRedisModel.find_by_token({})
        assert_equal @getted_models.size, 1, "Should be only one with alias" 
        @getted_model = @getted_models.first
        assert_equal @getted_model.integer, @test_model.integer
      end
    
      should "be getted after change in alias" do
        getted_model = TestRedisModel.get_by_alias(:token ,@args)
        getted_model.symbol = "Test_token"
        getted_model.save
        assert_equal getted_model.integer, TestRedisModel.get_by_alias(:token ,:symbol => "Test_token").integer
      end
    end

  end
end