# -*- encoding : utf-8 -*-
require 'helper'
class ValidationTest < Test::Unit::TestCase
  context "Validation" do
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

    context "class" do     
      
      should "validate redis_key" do
        assert TestRedisModel.valid_key?(:string => "test")
        assert !TestRedisModel.valid_key?(:string => nil)
        assert !TestRedisModel.valid_key?()
      end

      should "validate redis_alias_key" do
        assert TestRedisModel.valid_alias_key?(:token, :symbol => :test)
        assert !TestRedisModel.valid_alias_key?(:token, :symbol => nil)
        assert !TestRedisModel.valid_alias_key?(:token)
      end

    end

    context "instance" do

      should "validate alias key" do
        assert @test_model.valid_alias_key?(:token)
      end

      should "validate key" do
        assert @test_model.valid_key?
      end

      should "return errors after valid?" do
        test = TestRedisModel.new()
        assert !test.valid?, "shouldn't be valid"
        assert_equal test.errors.messages.size, 2, "should have 2 errors (2 required fields)" 
        assert_equal test.error.messages.size, 2, "error should be asliased to errors" 
      end

      should "return errors and be aliased to error" do
        test = TestRedisModel.new()
        assert !test.valid?, "shouldn't be valid"
        assert_equal test.error, test.errors
      end

      should "not raise exeption on invalid initialize" do
        assert_nothing_raised { TestRedisModel.new() }
      end

      should "return false on save" do
        test_model = TestRedisModel.new()
        assert !test_model.save, "return false on save"
        assert test_model.errors.any?, "have any error"
      end

    end
  end
end