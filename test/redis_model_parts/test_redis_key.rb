# -*- encoding : utf-8 -*-
require 'helper'
class RedisKeyTest < Test::Unit::TestCase
  context "Redis key" do
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

    should "generate right search key" do
      @test_model.string = nil
      assert_equal @test_model.redis_key, "#{TestRedisModel.to_s.underscore}:key:*"
      assert_equal TestRedisModel.generate_key(@args.merge({:string => nil})), "#{TestRedisModel.to_s.underscore}:key:*"
    end  

         
    should "generate right key" do
      assert_equal @test_model.redis_key, "#{TestRedisModel.to_s.underscore}:key:foo"
      assert_equal TestRedisModel.generate_key(@args), "#{TestRedisModel.to_s.underscore}:key:foo"
    end  

    should "generate right key alias" do
      assert_equal @test_model.redis_alias_key(:token), "#{TestRedisModel.to_s.underscore}:alias:token:bar"
      assert_equal TestRedisModel.generate_alias_key(:token, @args), "#{TestRedisModel.to_s.underscore}:alias:token:bar"
    end  

    context "invalid setting" do
      should "raise ArgumentError on nonexisting field" do
        assert_raises ArgumentError do
          class RedisKeyNonExistingKeyRedisModel
            include RedisModelExtension
            redis_field :string,  :string
            redis_key :unknown
          end
        end
      end

      should "raise ArgumentError on using Array as redis key" do
        assert_raises ArgumentError do
          class RedisKeyNonExistingKeyRedisModel
            include RedisModelExtension
            redis_field :array,  :array
            redis_key :array
          end
        end
      end

      should "raise ArgumentError on using Hash as redis key" do
        assert_raises ArgumentError do
          class RedisKeyNonExistingKeyRedisModel
            include RedisModelExtension
            redis_field :array,  :array
            redis_key :array
          end
        end
      end

    end

    context "normalization" do
      should "downcase" do
        class DowncaseRedisModel
          include RedisModelExtension
          redis_field :string,  :string
          redis_key :string
          redis_key_normalize :downcase
        end
        model = DowncaseRedisModel.new(:string => "FoO")
        assert_equal model.redis_key, "#{DowncaseRedisModel.to_s.underscore}:key:foo"
      end

      should "transliterate" do
        class TransliterateRedisModel
          include RedisModelExtension
          redis_field :string,  :string
          redis_key :string
          redis_key_normalize :transliterate
        end
        model = TransliterateRedisModel.new(:string => "FoOšČ")
        assert_equal model.redis_key, "#{TransliterateRedisModel.to_s.underscore}:key:FoOsC"
      end

      should "downcase & transliterate" do
        class DowncaseTransliterateRedisModel
          include RedisModelExtension
          redis_field :string,  :string
          redis_key :string
          redis_key_normalize :transliterate
          redis_key_normalize :downcase
        end
        model = DowncaseTransliterateRedisModel.new(:string => "FoOšČ")
        assert_equal model.redis_key, "#{DowncaseTransliterateRedisModel.to_s.underscore}:key:foosc"
      end

      should "downcase & transliterate in one setting" do
        class DowncaseTransliterateOneRedisModel
          include RedisModelExtension
          redis_field :string,  :string
          redis_key :string
          redis_key_normalize :transliterate, :downcase
        end
        model = DowncaseTransliterateOneRedisModel.new(:string => "FoOšČ")
        assert_equal model.redis_key, "#{DowncaseTransliterateOneRedisModel.to_s.underscore}:key:foosc"
      end

    end
  end
end