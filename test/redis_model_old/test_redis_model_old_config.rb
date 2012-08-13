# -*- encoding : utf-8 -*-
require 'helper'
class RedisModelOldConfigTest < Test::Unit::TestCase
  context "Old RedisModel config" do
    setup do
      RedisModelExtension::Database.redis.flushdb

      @args = {"integer" => 12345, :string => "foo", :symbol => :bar, :boolean => true, :array => [1,2,3], :hash => {"foo"=>"bar", "test" => 2}}
      @test_model = TestOldRedisModel.new(@args)
      @test_model_partial = TestOldRedisModel.new(:integer => 12345, :string => "foo")
    end 
    
    should "have same configuration" do
      assert_equal TestOldRedisModel.conf, TestOldRedisModel::REDIS_MODEL_CONF, "Same configuration"
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
      end
      
      should "return valid exists?" do
        assert_equal @test_model.integer?, true
        assert_equal @test_model.string?, true
        assert_equal @test_model.symbol?, true
        assert_equal @test_model.boolean?, true
        assert_equal @test_model.array?, true
        assert_equal @test_model.hash?, true
        
        assert_equal @test_model_partial.integer?, true
        assert_equal @test_model_partial.string?, true
        assert_equal @test_model_partial.symbol?, false
        assert_equal @test_model_partial.boolean?, false
        assert_equal @test_model_partial.hash?, false
        assert_equal @test_model_partial.array?, false
      end
      
      should "be assign new values" do
        @test_model.integer = 54321
        @test_model.string = "bar"
        @test_model.symbol = :foo
        @test_model.boolean = false
        @test_model.array = [4,5,6]
        @test_model.hash = {"bar" => "foo"}
        assert_equal @test_model.integer, 54321
        assert_equal @test_model.string, "bar"
        assert_equal @test_model.symbol, :foo
        assert_equal @test_model.boolean, false
        assert_equal @test_model.array, [4,5,6]
        assert_equal @test_model.hash, {"bar" => "foo"}
      end
    end
         
    context "redis key" do
      should "generate right key" do
        assert_equal @test_model.redis_key, "#{TestOldRedisModel.to_s.underscore}:key:foo"
        assert_equal TestOldRedisModel.generate_key(@args), "#{TestOldRedisModel.to_s.underscore}:key:foo"
      end  
      should "generate right key alias" do
        assert_equal @test_model.redis_alias_key(:token), "#{TestOldRedisModel.to_s.underscore}:alias:token:bar"
        assert_equal TestOldRedisModel.generate_alias_key(:token, @args), "#{TestOldRedisModel.to_s.underscore}:alias:token:bar"
      end  
    end
    
    context "after initialize" do 
      should "clear input arguments" do
        test_model = TestOldRedisModel.new(@args.merge({:foor => :bar, :not_in_fields => "foo"}))
        assert_same_elements test_model.args, @args.symbolize_keys!
      end
    end
    
    context "validation" do

      should "return errors after valid?" do
        test = TestOldRedisModel.new()
        assert !test.valid?, "shouldn't be valid"
        assert_equal test.errors.messages.size, 2, "should have 2 error (2 required field)" 
      end

      should "not raise exeption on invalid initialize" do
        assert_nothing_raised { TestOldRedisModel.new() }
      end

      should "return false on save" do
        test_model = TestOldRedisModel.new()
        assert !test_model.save, "return false on save"
        assert test_model.errors.any?, "have any error"
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
        @getted_model = TestOldRedisModel.get(@args)
        assert_equal @getted_model.integer, @test_model.integer
        assert_equal @getted_model.string, @test_model.string
        assert_equal @getted_model.symbol, @test_model.symbol
        assert_equal @getted_model.boolean, @test_model.boolean
      end

      should "have same elements after get and to_arg" do
        @getted_model = TestOldRedisModel.get(@args)
        assert_same_elements @getted_model.to_arg.to_json.split(","), @args.to_json.split(",")
      end
            
      context "alias" do
        should "be getted by alias" do
          @getted_model = TestOldRedisModel.get_by_alias(:token ,@args)
          assert_equal @getted_model.integer, @test_model.integer
          assert_equal @getted_model.string, @test_model.string
          assert_equal @getted_model.symbol, @test_model.symbol
          assert_equal @getted_model.boolean, @test_model.boolean
        end
        
        should "be getted after change in alias" do
          getted_model = TestOldRedisModel.get_by_alias(:token ,@args)
          getted_model.symbol = "Test_token"
          getted_model.save
          assert_equal getted_model.integer, TestOldRedisModel.get_by_alias(:token ,:symbol => "Test_token").integer
        end
      end
    end
    
    context "without rejected nil values on save" do
      setup do
        class NilTestOldRedisModel
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
        @args = {integer: 100, string: "test"}
        @nil_test_model = NilTestOldRedisModel.new(@args)
      end

      should "save nil values" do
        #on initialize
        assert_equal @nil_test_model.integer, 100
        assert_equal @nil_test_model.string, "test"
        @nil_test_model.save

        #after find
        founded = NilTestOldRedisModel.get(@args)
        assert_equal founded.integer, 100
        assert_equal founded.string, "test"

        #set integer to nil
        founded.integer = nil
        assert_equal founded.integer, nil
        #perform save
        founded.save

        #after second find
        founded = NilTestOldRedisModel.get(@args)
        assert_equal founded.integer, nil
        assert_equal founded.string, "test"

      end

      should "have same configuration" do
        assert_equal NilTestOldRedisModel.conf, NilTestOldRedisModel::REDIS_MODEL_CONF, "Same configuration"
      end
    end
  end
end