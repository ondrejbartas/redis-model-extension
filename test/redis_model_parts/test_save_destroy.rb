# -*- encoding : utf-8 -*-
require 'helper'
class SaveDestroyTest < Test::Unit::TestCase
  context "Save, Update & Destroy" do
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
        :float => 12.54,
      }
      @test_model = TestRedisModel.new(@args)
    end 
    
    context "saving" do
      setup do
        @test_model.save
      end
      
      should "be saved and then change of variable included in key should rename it in redis!" do
        assert_equal RedisModelExtension::Database.redis.keys("*").size, 2 #including key and alias
        @test_model.string = "change_of_strging"
        @test_model.save
        assert_equal RedisModelExtension::Database.redis.keys("*").size, 2 #including key and alias
      end

      should "have same elements after get" do
        @getted_model = TestRedisModel.get(@args)
        assert_equal @getted_model.integer, @test_model.integer
        assert_equal @getted_model.string, @test_model.string
        assert_equal @getted_model.symbol, @test_model.symbol
        assert_equal @getted_model.boolean, @test_model.boolean
      end

      should "have same elements after get and to_arg" do
        @getted_model = TestRedisModel.get(@args)
        assert_same_elements @getted_model.to_arg.keys, @args.keys
        assert_equal @getted_model.to_arg.values.collect{|a| a.to_s}.sort.join(","), @args.values.collect{|a| a.to_s}.sort.join(",")
      end

    end

    context "updating" do
      setup do
        @new_args = {:integer => 123457, :string => "bar", :symbol => :foo, :boolean => false}
      end

      should "change attributes" do
        @test_model.update @new_args
        assert_equal @test_model.integer, @new_args[:integer]
        assert_equal @test_model.string, @new_args[:string]
        assert_equal @test_model.symbol, @new_args[:symbol]
        assert_equal @test_model.boolean, @new_args[:boolean]
      end

      should "ignore unknown attributes and other normaly update" do
        @test_model.update @new_args.merge(:unknown => "attribute")
        assert_equal @test_model.integer, @new_args[:integer]
        assert_equal @test_model.string, @new_args[:string]
        assert_equal @test_model.symbol, @new_args[:symbol]
        assert_equal @test_model.boolean, @new_args[:boolean]
      end

    end

    context "destroy" do
    
      setup do
        @test_model.save
        @redis_key = @test_model.redis_key
      end
      
      should "remove key and aliases" do
        before =  RedisModelExtension::Database.redis.keys("*").size
        @test_model.destroy!
        assert_equal RedisModelExtension::Database.redis.keys("*").size, before-2 #including key and alias
      end

      should "not be found" do
        assert test = TestRedisModel.get(@args)
        test.destroy!
        assert_equal TestRedisModel.exists?(@args), false, "Should not exists"
      end
    
    end

  end
end