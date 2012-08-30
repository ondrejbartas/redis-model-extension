# -*- encoding : utf-8 -*-
require 'helper'
class DynamicAliasTest < Test::Unit::TestCase
  context "Dynamic alias" do
    setup do
      RedisModelExtension::Database.redis.flushdb
      @args = { 
        :name => "Foo", 
        :items => {
          :bar => "test",
          :foobar => "test2",
        },
        :items_order => [:foobar, :bar],
      }
      @dynamic_alias = DynamicAlias.new(@args)
    end 

    context "class" do    
      context "redis key" do

        should "be merged alias key + custom key" do
          assert_equal DynamicAlias.generate_alias_key(:items_with_name, @args), "dynamic_alias:alias:items_with_name:Foo:test2:test"
        end

        should "validate redis_alias_key" do
          assert DynamicAlias.valid_alias_key?(:items_with_name, @args), "full valid args"
          assert !DynamicAlias.valid_alias_key?(:items_with_name, :name => "Test"), "only main fields"
          assert !DynamicAlias.valid_alias_key?(:items_with_name, :items_order => [:foobar]), "only fields order"
          assert !DynamicAlias.valid_alias_key?(:items_with_name, :items_order => [:foobar], :items => {foobar: "test"}), "only fields order & items"
          assert !DynamicAlias.valid_alias_key?(:items_with_name), "no args"
        end

      end
    end

    context "instance" do    
      context "redis key" do

        should "return valid key" do
          assert_equal DynamicAlias.new(@args).redis_alias_key(:items_with_name), "dynamic_alias:alias:items_with_name:Foo:test2:test"
        end

        should "validate key" do
          dyn_alias = DynamicAlias.new(@args)
          assert_equal dyn_alias.valid_alias_key?(:items_with_name), true
          dyn_alias.items_order = nil
          assert_equal dyn_alias.valid_alias_key?(:items_with_name), false
        end

      end
    end
    
    context "saving & destroy" do
      setup do
        @dynamic_alias.save
        @redis_key = @dynamic_alias.redis_key
        @redis_dynamic_alias_key = @dynamic_alias.redis_alias_key(:items_with_name)
      end
      
      should "be saved and then change of variable included in key should rename it in redis!" do
        before = RedisModelExtension::Database.redis.keys("*").size
        assert @dynamic_alias.alias_exists?(:items_with_name), "Dynamic alias should exists"
        @dynamic_alias.name = "change_of_string"
        @dynamic_alias.save
        assert_equal RedisModelExtension::Database.redis.keys("*").size, before, "after update there should be same number of keys" #including key and alias
      end
  
      should "remove key and aliases" do
        before =  RedisModelExtension::Database.redis.keys("*").size
        @dynamic_alias.destroy!
        assert_equal RedisModelExtension::Database.redis.keys("*").size, before-2 #including key and alias
      end

      should "destroy!" do
        @dynamic_alias.destroy!
        assert_equal @dynamic_alias.exists?, false, "Should not exists"
        assert_equal DynamicAlias.exists?(@args.merge(:name => @dynamic_alias.name)), false, "Should not exist by class method"
      end
    
    end


    context "find & get" do
      
      setup do
        @dynamic_alias.save
      end

      should "be getted by dynamic alias" do
        @getted_models = DynamicAlias.get_by_alias(:items_with_name, @args)
        assert_not_nil @getted_models, "Should return array"
        assert_equal @getted_models.size, 1, "Should return [] with 1 instance"
        @getted_model = @getted_models.first
        assert_equal @getted_model.name, @dynamic_alias.name
        assert_same_elements @getted_model.items.to_json.split(","), @dynamic_alias.items.to_json.split(",")
      end

      should "be getted by get_by_name_of_alias" do
        @getted_models = DynamicAlias.get_by_items_with_name(@args)
        assert_not_nil @getted_models, "Should return array"
        assert_equal @getted_models.size, 1, "Should return [] with 1 instance"
        @getted_model = @getted_models.first
        assert_equal @getted_model.name, @dynamic_alias.name
        assert_same_elements @getted_model.items.to_json.split(","), @dynamic_alias.items.to_json.split(",")
      end

      should "be find by dynamic alias" do
        @getted_models = DynamicAlias.find_by_alias(:items_with_name, :items => {:bar => "test"})
        assert_equal @getted_models.size, 1, "Should be only one with alias" 

        @getted_models = DynamicAlias.find_by_alias(:items_with_name, @args)
        assert_equal @getted_models.size, 1, "Should be find by get by alias full args" 
        
        @getted_model = @getted_models.first
        assert_equal @getted_model.name, @dynamic_alias.name
        assert_same_elements @getted_model.items.to_json.split(","), @dynamic_alias.items.to_json.split(",")
      end

      should "be found by find_by_name_of_alias" do
        @getted_models = DynamicAlias.find_by_items_with_name(:items => {:bar => "test"})
        assert_equal @getted_models.size, 1, "Should be only one with alias" 

        @getted_models = DynamicAlias.find_by_items_with_name(@args)
        assert_equal @getted_models.size, 1, "Should be find by get by alias full args" 
        
        @getted_model = @getted_models.first
        assert_equal @getted_model.name, @dynamic_alias.name
        assert_same_elements @getted_model.items.to_json.split(","), @dynamic_alias.items.to_json.split(",")
      end
    
      should "be find all by dynamic alias" do
        @getted_models = DynamicAlias.find_by_alias(:items_with_name ,{})
        assert_equal @getted_models.size, 1, "Should be only one with alias" 
        @getted_model = @getted_models.first
        assert_equal @getted_model.name, @dynamic_alias.name
        assert_same_elements @getted_model.items.to_json.split(","), @dynamic_alias.items.to_json.split(",")
      end
    
      should "be getted after change in alias" do
        @getted_model = DynamicAlias.get_by_alias(:items_with_name ,@args).first
        assert_not_nil @getted_model, "Should return model"
        @getted_model.items[:bar] = "Test_bar"
        @getted_model.save
        assert_equal DynamicAlias.get_by_alias(:items_with_name ,@getted_model.to_arg).first.name, @getted_model.name
        assert_nil DynamicAlias.get_by_alias(:items_with_name ,@args), "Should not be found by old alias"
      end
    end

  end
end
