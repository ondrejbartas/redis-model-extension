# -*- encoding : utf-8 -*-
require 'helper'
class RedisModelTest < Test::Unit::TestCase
  context "Redis Model" do

    context "without rejected nil values on save" do
      should "save nil values" do
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

        class NilTestRedisModel
          include RedisModelExtension
          redis_field :integer, :integer
          redis_field :string, :string
          redis_key :string
          redis_save_fields_with_nil true
        end

        [NilTestOldRedisModel, NilTestRedisModel].each do |klass|
          args = {integer: 100, string: "test"}
          nil_test_model = klass.new(args)

          #on initialize
          assert_equal nil_test_model.integer, 100, "For #{klass} should have integer = 100"
          assert_equal nil_test_model.string, "test", "For #{klass} should have string = test"
          nil_test_model.save

          #after find
          founded = klass.get(args)
          assert_equal founded.integer, 100, "After get for #{klass} should have integer = 100"
          assert_equal founded.string, "test", "After get for #{klass} should have string = test"

          #set integer to nil
          founded.integer = nil
          assert_equal founded.integer, nil, "After get and save for #{klass} should have integer = nil"
          #perform save
          founded.save

          #after second find
          founded = klass.get(args)
          assert_equal founded.integer, nil, "After 2nd get for #{klass} should have integer = nil"
          assert_equal founded.string, "test", "After 2nd get for #{klass} should have string = test"
        end

      end
    end
    
  end
end