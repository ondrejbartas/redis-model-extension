# Redis Model

Redis model is basic implementation of few methods for creating model which store data in Redis

## Instalation

Just in console

``` ruby
gem install redis-model-extension
```

Or put into Gemfile

``` ruby
gem "redis-model-extension"
```

and somewhere before use (not rails - they will require gem automaticaly)
``` ruby
require "redis-model-extension"
```

## Initialization

You can use yml config file `redis_config.yml` in `config` directory:

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

Or last way to set redis is by providing only config arguments:
Use this in your initializer and when you use Forks or resque workers this will work very nicely, 
unless you will call to redis before workers are initialized.
Then you will get error Redis instance cannot be used in Forks. 
You can fix this by calling in the start of worker: `RedisModelExtension::Database.redis = nil`
This will remove old not possible to use redis instance and in first call to redis will use new config and create new redis instance.

``` ruby
RedisModelExtension::Database.redis_config(:host => "127.0.0.1", :port => 6379, :db => 0)
```

## Usage

Your class needs to include RedisModel and there is your testing configuration:
([old initialization - still working :)](https://github.com/ondrejbartas/redis-model-extension/wiki/Old-initialization))

``` ruby
class TestRedisModel
  include RedisModelExtension

  #REQUIRED:
  #redis_field :name_of_field, :filed_type, (:default_value - optional)
  redis_field :field1,    :integer
  redis_field :field2,    :bool
  redis_field :field3,    :string, "Default string"
  redis_field :field4,    :symbol
  redis_field :field5,    :array
  redis_field :field6,    :hash
  redis_field :field7,    :time
  redis_field :field8,    :date
  
  # which columns are used for generating redis key - name_of_your_class:key:field1:field2...
  redis_key :field1, :field2

  #OPTIONALS:
  # redis_validate :field1, :field2... #test your model, if all specified variables are not nil
  redis_validate :field1, :field3 

  # redis alias is working as redis key, but it will only create alias to your main hash in redis
  # specified is by combination of uniq value (you specify which fields to use)
  # redis_alias :name_of_alias, <array of field names>
  redis_alias :token, [:field4]
end

foo = TestRedisModel.new()

# you can validate your object

if foo.valid?
  foo.save #save object
else
  puts foo.errors #you can get nice errors what is wrong
end

# custom errors in initialize etc.
#class declaration
def initialize args = {}
  error << "My custom error"
  super args
end
#then valid? will produce false and when asked instance.errors you will get array with your errors


#you can update more attributes at once
foo.update(:field1 => 234, :field3 => "bar")

# !!! if you try to save invalid object you will get ArgumentError exception !!!

# after save you can find and get object find_by_alias

#this will return array of all object witch has string with value "foo"
#you can perfor find only with keys which are in redis key
#this is slow variant for redis but compared to other databases super fast :-)
#if you specify all keys from redis key it will perform faster method get
TestRedisModel.find(:field3 => "foo") 

#you can use get method if you know all keys used in redis key
#this variant is super fast
TestRedisModel.get(:field3 => "foo", :field4=> true) 

#you can ask redis if this item exists
TestRedisModel.exists?(:field3 => "foo", :field4=> true) 

#you can try to find by alias - alias needs to be uniq 
#use alias only for uniq combination of keys
TestRedisModel.find_by_alias(:token, :field4=> true) 

```

Now you can easily access all attributes from TestRedisModel by `foo.integer` or exists? `foo.integer?` or set value by `foo.integer = 1234` 

You can initialize model by `foo = TestRedisModel.new(:field1 => 123, :field3 => "bar")` and then access it same as above.

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