# -*- encoding : utf-8 -*-
require 'simplecov'
SimpleCov.start do 
  add_filter "/test/"
  add_filter "/config/"
  add_filter "database"
  
  add_group 'Lib', 'lib/'
end

require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'
require 'mocha'
require 'turn'
require 'shoulda-context'
require 'json'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'redis-model-extension'

require File.expand_path(File.join(File.dirname(__FILE__),'models.rb'))

#clear database connection
RedisModelExtension::Database.redis = nil