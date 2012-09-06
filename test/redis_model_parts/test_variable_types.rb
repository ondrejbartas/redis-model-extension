# -*- encoding : utf-8 -*-
require 'helper'
class VariableTypesTest < Test::Unit::TestCase
  context "Definition & Types of variables" do
    setup do
      RedisModelExtension::Database.redis.flushdb

      @time = Time.now
      @args = {
        "integer" => 12345, 
        :string => "foo", 
        :symbol => :bar, 
        :boolean => true, 
        :array => [1,2,3], 
        :field_hash => {"foo"=>"bar", "test" => 2},
        :field_marshal => {"foo"=>"bar", "test" => 2, :bar => { "test" => [:foo,"bar"]} },
        :time => @time, 
        :date => Date.today,
        :float => 12.43,
      }
      @test_model = TestRedisModel.new(@args)
      @test_model_partial = TestRedisModel.new(:integer => 12345, :string => "foo")
    end 
    
    context "on invalid type" do 
      should "return not modified value" do
        assert_equal @test_model.value_transform("Test", :unknown_type), "Test", "Value transform"
        assert_equal @test_model.value_parse("Test", :unknown_type), "Test", "Value parse"
        assert_equal @test_model.value_to_redis(:unknown_field_name, "Test"), "Test", "Value to redis"
      end
    end

    should "get valid arguments" do
      assert_equal @test_model.integer, 12345
      assert_equal @test_model.string, "foo"
      assert_equal @test_model.symbol, :bar
      assert_equal @test_model.boolean, true
      assert_equal @test_model.array, [1,2,3]
      assert_equal @test_model.field_hash, {:foo=>"bar", :test => 2}
      assert_equal @test_model.field_marshal, @args[:field_marshal]
      assert_equal @test_model.time, @time
      assert_equal @test_model.date, Date.today
      assert_equal @test_model.float, 12.43
    end
    
    should "return default value when value is nil" do
      assert_equal @test_model_partial.symbol, :default
    end

    should "return valid exists?" do
      assert_equal @test_model.integer?, true
      assert_equal @test_model.string?, true
      assert_equal @test_model.symbol?, true
      assert_equal @test_model.boolean?, true
      assert_equal @test_model.array?, true
      assert_equal @test_model.field_hash?, true
      assert_equal @test_model.field_marshal?, true
      assert_equal @test_model.time?, true
      assert_equal @test_model.date?, true
      assert_equal @test_model.float?, true
      
      assert_equal @test_model_partial.integer?, true
      assert_equal @test_model_partial.string?, true
      assert_equal @test_model_partial.symbol?, true, "should be set by default value"
      assert_equal @test_model_partial.boolean?, false
      assert_equal @test_model_partial.field_hash?, false
      assert_equal @test_model_partial.field_marshal?, false
      assert_equal @test_model_partial.array?, false
      assert_equal @test_model_partial.time?, false
      assert_equal @test_model_partial.date?, false
      assert_equal @test_model_partial.float?, false
    end
    
    should "be assign new values" do
      @test_model.integer = 54321
      @test_model.string = "bar"
      @test_model.symbol = :foo
      @test_model.boolean = false
      @test_model.array = [4,5,6]
      @test_model.field_hash = {:bar => "foo"}
      @test_model.field_marshal = {"bar" => ["foo", :bar]}
      @test_model.time = @time-100
      @test_model.date = Date.today-10
      @test_model.float = 25.43
      assert_equal @test_model.integer, 54321
      assert_equal @test_model.string, "bar"
      assert_equal @test_model.symbol, :foo
      assert_equal @test_model.boolean, false
      assert_equal @test_model.array, [4,5,6]
      assert_equal @test_model.field_hash, {:bar => "foo"}
      assert_equal @test_model.field_marshal, {"bar" => ["foo", :bar]}
      assert_equal @test_model.time, @time-100
      assert_equal @test_model.date, Date.today-10
      assert_equal @test_model.float, 25.43
    end
  end
end
