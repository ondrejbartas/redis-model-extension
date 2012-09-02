# -*- encoding : utf-8 -*-

class TestOldRedisModel
  REDIS_MODEL_CONF = {
     :fields => { 
       :integer => :to_i,
       :boolean => :to_bool,
       :string => :to_s,
       :symbol => :to_sym,
       :array => :to_array,
       :field_hash => :to_hash,
      }, 
      :required => [:integer, :string],
      :redis_key => [:string],
      :redis_aliases => {
        :token => [:symbol]
      },
      :reject_nil_values => true,
   }
   include RedisModel
   initialize_redis_model_methods REDIS_MODEL_CONF
end

class TestRedisModel
  include RedisModelExtension
  redis_field :integer, :integer
  redis_field :boolean, :bool
  redis_field :string,  :string
  redis_field :symbol,  :symbol, :default
  redis_field :array,   :array
  redis_field :field_hash, :hash
  redis_field :time,    :time
  redis_field :date,    :date
  redis_field :float,   :float

  validates :integer, :presence => true
    
  redis_key :string

  redis_alias :token, [:symbol]

end

class AutoincrementNotSet
  include RedisModelExtension
  redis_field :name, :string
  redis_field :email, :string
end

class AutoincrementSetRedisKey
  include RedisModelExtension
  redis_field :name, :string
  redis_field :email, :string
  redis_key [:id]
end

class DynamicAlias
  include RedisModelExtension
  redis_field :name,  :string
  redis_field :items, :hash
  redis_key :name
  redis_alias :items_with_name, [:name], :items_order, :items
end

class WithCallbacks
  include RedisModelExtension

  before_save    :before_save_method
  after_save     :after_save_method
  before_destroy { @destroyed_flag = true }
  before_create  :before_create_method

  redis_field :name, :string

  def before_save_method
  end

  def after_save_method
  end

  def before_create_method
  end
end

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

class WithDirty
  include RedisModelExtension
  include RedisModelExtension::Dirty

  redis_field :first_field,  :string
  redis_field :second_field, :bool
  redis_field :third_field,  :integer

  redis_key :first_field
end
