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
      :redis_key => [:string],
      :redis_aliases => {
        :token => [:symbol]
      }
   }
   include RedisModel
   initialize_redis_model_methods REDIS_MODEL_CONF
end

foo = TestRedisModel.new()
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