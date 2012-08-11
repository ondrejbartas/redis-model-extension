# encoding: utf-8
ENV['RACK_ENV'] ||= "development"

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "redis-model-extension"
  gem.homepage = "http://github.com/ondrejbartas/redis-model-extension"
  gem.license = "MIT"
  gem.summary = %Q{Redis model is basic implementation of creating, finding, updating and deleting model which store data in Redis.}
  gem.description = %Q{It provides functions as find, find_by_alias, get, exists?, validate, save etc.}
  gem.email = "ondrej@bartas.cz"
  gem.authors = ["Ondrej Bartas"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test


#get directories!
PIDS_DIR = File.expand_path(File.join("..", "tmp","pid"), __FILE__)
CONF_DIR = File.expand_path(File.join("..", "config"), __FILE__)
#create directory for pid files
FileUtils.mkdir_p(PIDS_DIR) unless File.exists?(PIDS_DIR)
REDIS_PID = File.join(PIDS_DIR, "redis.pid")

#copy example config files for redis and elastic if they don't exists
FileUtils.cp(File.join(CONF_DIR, "redis_config.yml.example"), File.join(CONF_DIR, "redis_config.yml") ) unless File.exists?(File.join(CONF_DIR, "redis_config.yml")) 

#for testing purposes use 
REDIS_CNF = File.join(File.expand_path(File.join("..","config"), __FILE__), "redis_setup.conf")

desc "Run tests and manage databases start/stop"
task :run => [:'redis:start', :test, :'redis:stop']

desc "Start databases"
task :startup => [:'redis:start']

desc "Teardown databases"
task :teardown => [:'redis:stop']

namespace :redis do
  desc "Start the Redis server"
  task :start do
    redis_running = \
    begin
      File.exists?(REDIS_PID) && Process.kill(0, File.read(REDIS_PID).to_i)
    rescue Errno::ESRCH
      FileUtils.rm REDIS_PID
      false
    end
    system "pwd"
    puts system "redis-server #{REDIS_CNF}" unless redis_running
    puts "redis started"
  end

  desc "Stop the Redis server"
  task :stop do
    if File.exists?(REDIS_PID)
      Process.kill "INT", File.read(REDIS_PID).to_i
      FileUtils.rm REDIS_PID
      puts "redis stopped"
    end
  end
end