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

Lots of aditional informations can be found in [WIKI](https://github.com/ondrejbartas/redis-model-extension/wiki) or directly:

* [Auto-increment IDs](https://github.com/ondrejbartas/redis-model-extension/wiki/Auto-increment-IDs)
* [Validations](https://github.com/ondrejbartas/redis-model-extension/wiki/Validations)
* [Aliases](https://github.com/ondrejbartas/redis-model-extension/wiki/Aliases)
* [Update multiple attributes](https://github.com/ondrejbartas/redis-model-extension/wiki/Update-multiple-attributes)
* [Before After Hooks](https://github.com/ondrejbartas/redis-model-extension/wiki/Before-After-Hooks)
 
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

  # reddis_key_normalize - when assembling redis key you can specify normalization actions for values
  # :downcase - your_class:key:Value:FoO -> your_class:key:value:foo (find - case insensitive)
  # :transliterate - your_class:key:VašíČek:FoO -> your_class:key:VasiCek:FoO (find - without á,č etc.)
  # :downcase & :transliterate - your_class:key:VašíČek:FoO -> your_class:key:vasicek:foo
  # this is crucial for find method
  reddis_key_normalize :transliterate, :downcase

  # redis alias is working as redis key, but it will only create alias to your main hash in redis
  # specified is by combination of uniq value (you specify which fields to use)
  # redis_alias :name_of_alias, <array of field names>
  redis_alias :token, [:field4]
end

foo = TestRedisModel.new()

# you can set/get values
foo.field3
#=> "Default string" #getting default value
foo.field3 = "bar"
#=> "bar"
foo.field3
#=> "bar"

#you can get all attributes by calling
foo.to_args
#or to JSON
foo.to_json

#you can update more attributes at once
foo.update(:field1 => 234, :field3 => "bar")

# you can validate your object

foo.valid?
#=> true | false -> depending on validations

#You can save
unless foo.save #save returns instance -> valid save | false -> some errors
  puts foo.errors #you can get nice errors what is wrong
end

# you can use create
bar = TestRedisModel.create field1: 123
# but don't forget to ask for errors
if (bar = TestRedisModel.create field1: 123).errors.any?
  puts bar.errors
end
# this will return if there was validation error before creation

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
TestRedisModel.find_by_alias :token, :field4=> true
# or by generated method:
TestRedisModel.find_by_token :field4=> true
# if nothing exists
#=> nil
# if there is saved something
#=> [<TestRedisModel: ...>, <TestRedisModel: ...>, ...]
```

## Dirty

If you want to use ActiveModel::Dirty, i.e. methods like `_changed?`, `_was?` you can include
a Dirty module to your model (right after RedisModelExtension)
```ruby
class MyModel
  include RedisModelExtension
  include RedisModelExtension::Dirty
end
```

## Change log

* 0.4.2 
 * Add ActiveModel::Dirty
 * Change work with attributes to ActiveModel::Attributes
* 0.4.1 
 * Fixed bugs in intialization
 * Changed aliases to use key - array instead of key - value (enable find by category...) WIKI: [Aliases](https://github.com/ondrejbartas/redis-model-extension/wiki/Aliases)
 * Add better readme and filled [WIKI](https://github.com/ondrejbartas/redis-model-extension/wiki)
* 0.4.0 
 * Redesigned initialization method from: [old one](https://github.com/ondrejbartas/redis-model-extension/wiki/Old-initialization) to: [new one](https://github.com/ondrejbartas/redis-model-extension/wiki/New-initialization)
 * Added [Before After Hooks](https://github.com/ondrejbartas/redis-model-extension/wiki/Before-After-Hooks)
 * Added [Auto-increment IDs](https://github.com/ondrejbartas/redis-model-extension/wiki/Auto-increment-IDs)
 * Added dynamic aliases
 * Added [Active Model Validations](https://github.com/ondrejbartas/redis-model-extension/wiki/Validations)
 * REFACTORED whole structure of redis model (similar methods moved to separate modules)
 * Set default to save nil values to redis
* 0.3.8
 * Allow to don't save nil values into redis
* 0.3.7
 * Fix dependencies
* 0.3.6
 * Fix problem with working in Forks
* for older look at [Commit messages](https://github.com/ondrejbartas/redis-model-extension/commits/master)

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
