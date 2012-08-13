# -*- encoding : utf-8 -*-
require 'helper'
class AttributesTest < Test::Unit::TestCase
  context "Attributes" do
    setup do
      @time = Time.now
      @args = {
        "integer" => 12345, 
        :string => "foo", 
        :symbol => :bar, 
        :boolean => true, 
        :array => [1,2,3], 
        :hash => {:foo=>"bar", :test => 2}, 
        :time => @time, 
        :date => Date.today,
        :float => 12.32,
      }
      @test_model = TestRedisModel.new(@args)
    end 
         
    context "after initialize" do 
      should "clear input arguments" do
        test_model = TestRedisModel.new(@args.merge({:foor => :bar, :not_in_fields => "foo"}))
        assert_same_elements test_model.args, @args.symbolize_keys
      end
    end

    should "should create valid to_json" do
      #keys in json are in different order, just spliting by separator (comma) and then validating
      assert_same_elements @test_model.to_json.split(","), @args.to_json.split(",")
    end

    should "should access hash by []" do
      assert_equal @test_model.hash[:foo], "bar"
    end

    should "should access hash by hashr" do
      assert_equal @test_model.hash.foo, "bar"
    end

  end
end