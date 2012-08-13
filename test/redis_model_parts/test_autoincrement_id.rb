# -*- encoding : utf-8 -*-
require 'helper'
class RedisModelAutoincrementTest < Test::Unit::TestCase
  context "Autoincrement" do

    setup do
      RedisModelExtension::Database.redis.flushdb
      @args = {
        name: "Author",
        email: "ondrej@bartas.cz"
      }
    end

    context "without redis_key specified" do
    
      should "have redis_key with id" do
        assert_equal AutoincrementNotSet.redis_key_config, [:id]
        assert AutoincrementNotSet.new.respond_to?(:id), "get method"
        assert AutoincrementNotSet.new.respond_to?(:"id?"), "exists? method"
        assert !AutoincrementNotSet.new.respond_to?(:"id="), "set method"
      end

      should "be valid?" do
        assert AutoincrementNotSet.new(@args).valid?
      end

    end

    context "with redis_key specified" do
    
      should "have redis_key with id" do
        assert_equal AutoincrementSetRedisKey.redis_key_config, [:id]
        assert AutoincrementSetRedisKey.new.respond_to?(:id), "get method"
        assert AutoincrementSetRedisKey.new.respond_to?(:"id?"), "exists? method"
        assert !AutoincrementSetRedisKey.new.respond_to?(:"id="), "set method"
      end

      should "be valid?" do
        assert AutoincrementSetRedisKey.new(@args).valid?
      end

      should "after save have id" do
        saved_instance = AutoincrementSetRedisKey.new(@args)
        saved_instance.save
        assert_equal saved_instance.id, 1, "Should be first id 1"
      end

      should "be getted by directly id" do
        saved_instance = AutoincrementSetRedisKey.new(@args)
        saved_instance.save
        assert getted_instance = AutoincrementSetRedisKey.get(saved_instance.id), "should be getted by id: #{saved_instance.id}"
        assert_same_elements getted_instance.to_arg.to_json.split(","), saved_instance.to_arg.to_json.split(",")
      end

      should "be founded by directly id" do
        saved_instance = AutoincrementSetRedisKey.new(@args)
        saved_instance.save
        assert getted_instances = AutoincrementSetRedisKey.find(saved_instance.id), "should be getted by id: #{saved_instance.id}"
        assert_equal getted_instances.size, 1, "should be array with one element"
        getted_instance = getted_instances.first
        assert_same_elements getted_instance.to_arg.to_json.split(","), saved_instance.to_arg.to_json.split(",")
      end

      should "not enable to set id unless id exists" do
        assert_raises ArgumentError do
          AutoincrementSetRedisKey.new(@args.merge(:id => 10))
        end
        saved_instance = AutoincrementSetRedisKey.new(@args)
        saved_instance.save
        assert_nothing_raised do
          AutoincrementSetRedisKey.new(@args.merge(:id => saved_instance.id))
        end
      end

    end


  end
end