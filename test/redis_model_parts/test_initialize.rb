# -*- encoding : utf-8 -*-
require 'helper'
class VariableTypesTest < Test::Unit::TestCase
  context "Definition & Types of variables" do
    setup do
      RedisModelExtension::Database.redis.flushdb

      @test_model = TestRedisModel.new()
    end 
    
    should "be have accessible fields" do
      assert @test_model.respond_to?(:integer)
      assert @test_model.respond_to?(:string)
      assert @test_model.respond_to?(:boolean)
      assert @test_model.respond_to?(:array)
      assert @test_model.respond_to?(:field_hash)
      assert @test_model.respond_to?(:time)
      assert @test_model.respond_to?(:date)
      assert @test_model.respond_to?(:float)
    end

    should "be have setable fields" do
      assert @test_model.respond_to?(:"integer=")
      assert @test_model.respond_to?(:"string=")
      assert @test_model.respond_to?(:"boolean=")
      assert @test_model.respond_to?(:"array=")
      assert @test_model.respond_to?(:"field_hash=")
      assert @test_model.respond_to?(:"time=")
      assert @test_model.respond_to?(:"date=")
      assert @test_model.respond_to?(:"float=")
    end

    should "be have field exist?" do
      assert @test_model.respond_to?(:"integer?")
      assert @test_model.respond_to?(:"string?")
      assert @test_model.respond_to?(:"boolean?")
      assert @test_model.respond_to?(:"array?")
      assert @test_model.respond_to?(:"field_hash?")
      assert @test_model.respond_to?(:"time?")
      assert @test_model.respond_to?(:"date?")
      assert @test_model.respond_to?(:"float?")
    end    

    should "say if class has attribute method" do
      assert TestRedisModel.attribute_method?(:integer)
      refute TestRedisModel.attribute_method?(:nonexisting)
    end

  end
end
    
