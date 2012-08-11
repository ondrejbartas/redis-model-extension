# -*- encoding : utf-8 -*-
require 'helper'
class RedisModelTest < Test::Unit::TestCase
  context "RedisModel" do
    setup do
      RedisModelExtension::Database.redis.flushdb
      
      class TestRedisModel
        include RedisModel
        redis_field :integer, :integer
        redis_field :boolean, :bool
        redis_field :string,  :string
        redis_field :symbol,  :symbol, :default
        redis_field :array,   :array
        redis_field :hash,    :hash
        redis_field :time,    :time
        redis_field :date,    :date
        
        redis_validate :integer, :string 
        redis_key :string

        redis_alias :token, [:symbol]

      end
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
      @test_model_partial = TestRedisModel.new(:integer => 12345, :string => "foo")
    end 
    
    context "define methods" do
      should "be accessible" do
        assert @test_model.respond_to?(:integer)
        assert @test_model.respond_to?(:boolean)
        assert @test_model.respond_to?(:string)
        assert @test_model.respond_to?(:symbol)
      end
      
      should "get valid arguments" do
        assert_equal @test_model.integer, 12345
        assert_equal @test_model.string, "foo"
        assert_equal @test_model.symbol, :bar
        assert_equal @test_model.boolean, true
        assert_equal @test_model.array, [1,2,3]
        assert_equal @test_model.hash, {"foo"=>"bar", "test" => 2}
        assert_equal @test_model.time, @time
        assert_equal @test_model.date, Date.today
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
        assert_equal @test_model.hash?, true
        assert_equal @test_model.time?, true
        assert_equal @test_model.date?, true
        
        assert_equal @test_model_partial.integer?, true
        assert_equal @test_model_partial.string?, true
        assert_equal @test_model_partial.symbol?, true, "should be set by default value"
        assert_equal @test_model_partial.boolean?, false
        assert_equal @test_model_partial.hash?, false
        assert_equal @test_model_partial.array?, false
        assert_equal @test_model_partial.time?, false
        assert_equal @test_model_partial.date?, false
      end
      
      should "be assign new values" do
        @test_model.integer = 54321
        @test_model.string = "bar"
        @test_model.symbol = :foo
        @test_model.boolean = false
        @test_model.array = [4,5,6]
        @test_model.hash = {"bar" => "foo"}
        @test_model.time = @time-100
        @test_model.date = Date.today-10
        assert_equal @test_model.integer, 54321
        assert_equal @test_model.string, "bar"
        assert_equal @test_model.symbol, :foo
        assert_equal @test_model.boolean, false
        assert_equal @test_model.array, [4,5,6]
        assert_equal @test_model.hash, {"bar" => "foo"}
        assert_equal @test_model.time, @time-100
        assert_equal @test_model.date, Date.today-10
      end
    end
         
    context "redis key" do
      should "generate right key" do
        assert_equal @test_model.redis_key, "#{TestRedisModel.to_s.underscore}:key:foo"
        assert_equal TestRedisModel.generate_key(@args), "#{TestRedisModel.to_s.underscore}:key:foo"
      end  
      should "generate right key alias" do
        assert_equal @test_model.redis_alias_key(:token), "#{TestRedisModel.to_s.underscore}:alias:token:bar"
        assert_equal TestRedisModel.generate_alias_key(:token, @args), "#{TestRedisModel.to_s.underscore}:alias:token:bar"
      end  
    end
    
    context "after initialize" do 
      should "clear input arguments" do
        test_model = TestRedisModel.new(@args.merge({:foor => :bar, :not_in_fields => "foo"}))
        assert_same_elements test_model.args, @args.symbolize_keys
      end
    end
    
    context "validation" do

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
            
      context "alias" do
        should "be getted by alias" do
          @getted_model = TestRedisModel.get_by_alias(:token ,@args)
          assert_equal @getted_model.integer, @test_model.integer
          assert_equal @getted_model.string, @test_model.string
          assert_equal @getted_model.symbol, @test_model.symbol
          assert_equal @getted_model.boolean, @test_model.boolean
        end
        
        should "be getted after change in alias" do
          getted_model = TestRedisModel.get_by_alias(:token ,@args)
          getted_model.symbol = "Test_token"
          getted_model.save
          assert_equal getted_model.integer, TestRedisModel.get_by_alias(:token ,:symbol => "Test_token").integer
        end
      end
    end
    
    context "without rejected nil values on save" do
      should "save nil values" do
        class NilTestRedisModel
          REDIS_MODEL_CONF = {
             :fields => { 
               :integer => :to_i,
               :string => :to_s,
              }, 
              :required => [:string],
              :redis_key => [:string],
              :redis_aliases => {},
              :reject_nil_values => false
           }
           include RedisModel
           initialize_redis_model_methods REDIS_MODEL_CONF
        end
        args = {integer: 100, string: "test"}
        nil_test_model = NilTestRedisModel.new(args)

        #on initialize
        assert_equal nil_test_model.integer, 100
        assert_equal nil_test_model.string, "test"
        nil_test_model.save

        #after find
        founded = NilTestRedisModel.get(args)
        assert_equal founded.integer, 100
        assert_equal founded.string, "test"

        #set integer to nil
        founded.integer = nil
        assert_equal founded.integer, nil
        #perform save
        founded.save

        #after second find
        founded = NilTestRedisModel.get(args)
        assert_equal founded.integer, nil
        assert_equal founded.string, "test"
      end
    end
  end
end