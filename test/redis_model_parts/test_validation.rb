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
        assert_equal test.errors.size, 2, "should have 2 errors (2 required fields)" 
      end

      should "be able to add custom error (ex. in initialize)" do
        test = TestRedisModel.new()
        test.error << "my custom error"
        assert !test.valid?, "shouldn't be valid"
        assert_equal test.errors.size, 3, "should have 3 errors (2 required fields + 1 custom error)" 
        assert_equal test.error.size, test.errors.size, "error and errors should be same (only as backup)" 
      end

      should "not raise exeption on invalid initialize" do
        assert_nothing_raised { TestRedisModel.new() }
      end

      should "raise exeption on save" do
        test_model = TestRedisModel.new()
        assert_raises ArgumentError do
          test_model.save
        end
      end

    end
  end
end