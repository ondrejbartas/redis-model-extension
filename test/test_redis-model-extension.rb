# -*- encoding : utf-8 -*-
require 'helper'
class RedisModelTest < Test::Unit::TestCase
  context "Redis Model" do

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