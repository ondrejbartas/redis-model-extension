# encoding: utf-8

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pp'
require 'benchmark'
require 'redis-model-extension'
COUNT = (ENV['COUNT'] || 10000).to_i

RedisModelExtension::Database.redis = Redis.new db: 15
RedisModelExtension::Database.redis.flushdb

class Movie
  include RedisModelExtension
  redis_field :name,     :string
  redis_field :director, :string
  redis_field :length,   :integer
  redis_field :object,   :hash
end

puts "Beginning the benchmark script", "", '='*80
sleep 5


puts "Saving #{COUNT} records into a Redis database..."

elapsed = Benchmark.realtime do
  (1..COUNT).map do |i|
    m = Movie.create name: "Move name #{i}", length: Random.rand(100..200), director: "Director #{i}", hash: { ttesting: "benchmark", and_more: {foo: :bar}}
    pp m.errors.to_a if m.errors.any?
  end
end

puts "Duration: #{elapsed} seconds, rate: #{COUNT.to_f/elapsed} docs/sec",
     '-'*80

puts "Finding all movies..."
elapsed = Benchmark.realtime do
  pp Movie.find().size
end
puts "Duration: #{elapsed} seconds, rate: #{COUNT.to_f/elapsed} docs/sec",
     '-'*80

puts "_"*80,"="*80
puts "ONLY REDIS"
puts "Saving #{COUNT} records into a Redis database..."

elapsed = Benchmark.realtime do
  (1..COUNT).map do |i|
    RedisModelExtension::Database.redis.hmset "movie:key:#{i}", "name","Move name #{i}", "length",Random.rand(100..200), "director", "Director #{i}", "hash", { ttesting: "benchmark", and_more: {foo: :bar}}.to_json
  end
end

puts "Duration: #{elapsed} seconds, rate: #{COUNT.to_f/elapsed} docs/sec",
     '-'*80

puts "Finding all movies..."
elapsed = Benchmark.realtime do
  RedisModelExtension::Database.redis.keys("movie:key:*").each do |key|
    RedisModelExtension::Database.redis.hgetall(key)
  end
end
puts "Duration: #{elapsed} seconds, rate: #{COUNT.to_f/elapsed} docs/sec",
     '-'*80


puts "Finding #{COUNT} movies one by one..."