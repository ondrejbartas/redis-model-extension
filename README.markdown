# Redis Model

Redis model is basic implementation of few methods for creating model which store data in Redis

## Initialization

You can use yml config file in `config` directory:

``` yml
test:
  host: "127.0.0.1"
  port: 6379
  db: 3
other omnited...
```

Or you can setup directly in initializer (or before any of redis call) redis instance directly:

``` ruby
RedisModelExtension::Database.redis = Redis.new(host: "127.0.0.1", port: 6379, db: 0)
```

## Usage

``` ruby
class TestRedisModel
  REDIS_MODEL_CONF = {
     :fields => { 
       :integer => :to_i,
       :boolean => :to_bool,
       :string => :to_s,
       :symbol => :to_sym,
      }, 
      :required => [:integer, :string],
      :redis_key => [:string, :symbol],
      :redis_aliases => {
        :token => [:symbol]
      }
   }
   include RedisModel
   initialize_redis_model_methods REDIS_MODEL_CONF
end

foo = TestRedisModel.new()

# you can validate your object

if foo.valid?
  foo.save #save object
else
  puts foo.errors #you can get nice errors what is wrong
end

#you can update more attributes at once
foo.update(:integer => 234, :string => "bar")

# !!! if you try to save invalid object you will get ArgumentError execption !!!

# after save you can find and get object find_by_alias

#this will return array of all object witch has string with value "foo"
#you can perfor find only with keys which are in redis key
#this is slow variant for redis but compared to other databases super fast :-)
#if you specify all keys from redis key it will perform faster method get
TestRedisModel.find(:string => "foo") 

#you can use get method if you know all keys used in redis key
#this variant is super fast
TestRedisModel.get(:string => "foo", :symbol=> true) 

#you can ask redis if this item exists
TestRedisModel.exists?(:string => "foo", :symbol=> true) 

#you can try to find by alias - alias needs to be uniq 
#use alias only for uniq combination of keys
TestRedisModel.find_by_alias(:token, :symbol=> true) 

```

Now you can easily access all attributes from TestRedisModel by `foo.integer` or exists? `foo.integer?` or set value by `foo.integer = 1234` 

You can initialize model by `foo = TestRedisModel.new(:integer => 123, :string => "bar")` and then access it same as above.

Saving is easy too: `foo.save` -> It will raise exception if :required attributes aren't filled. Error message says what is missing.



## Contributing to redis-model-extension
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Ondrej Bartas. See LICENSE.txt for
further details.