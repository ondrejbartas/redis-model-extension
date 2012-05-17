# -*- encoding : utf-8 -*-
require 'pp'
require 'yaml'
require 'redis'
require 'active_support'
require 'active_support/inflector'
require 'active_support/inflector/inflections'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/class/inheritable_attributes'
require 'string_to_bool'
require 'database'

module RedisModel

  attr_accessor :args, :error, :old_args, :conf
  
  def self.included(base) 
    base.send :extend, ClassMethods         
    base.send :include, InstanceMethods  
  end
  
  module ClassMethods
    
    def initialize_redis_model_methods conf
      @conf = conf
      #take all fields and make methods for them
      conf[:fields].each do |attr, action|
        define_method "#{attr}" do
          if self.args[attr] || self.args[attr] == false #== false is a fi for boolean variable
            self.args[attr].to_s.send(action)
          else
            nil
          end
        end
        
        define_method "#{attr}=" do |item|
          self.args[attr] = item
        end
        
        define_method "#{attr}?" do
          !self.args[attr].nil?
        end
      end  
    end
    
    def conf
      @conf
    end
    
    #Generates redis key for storing object
    def generate_key(args = {})
      out = "#{self.name.to_s.underscore.to_sym}:key"
      @conf[:redis_key].each do |key|
        if args.has_key?(key)
          out += ":#{args[key]}"
        else
          out += ":*"
        end
      end
      out
    end
    
    #Generates redis key for storing indexes for aliases
    def generate_alias_key(alias_name, args = {})
      out = "#{self.name.to_s.underscore.to_sym}:alias:#{alias_name}"
      @conf[:redis_aliases][alias_name.to_sym].each do |key|
        if args.has_key?(key)
          out += ":#{args[key]}"
        else
          out += ":*"
        end
      end
      out
    end
    
    #Validates if key by arguments is valid
    def valid_key?(args = {})
      full_key = true
      @conf[:redis_key].each do |key|
        full_key = false if !args.has_key?(key) || args[key].nil?
      end
      full_key
    end

    #Validates if key by alias name and arguments is valid
    def valid_alias_key?(alias_name, args = {})
      full_key = true
      @conf[:redis_aliases][alias_name.to_sym].each do |key|
        full_key = false if !args.has_key?(key) || args[key].nil?
      end
      full_key
    end

    #Check if key by arguments exists in db
    def exists?(args = {})
      Database.redis.exists(self.name.constantize.generate_key(args))
    end

    #Check if key by alias name and arguments exists in db
    def alias_exists?(alias_name, args = {})
      Database.redis.exists(self.name.constantize.generate_alias_key(alias_name, args))
    end

    #Wrapper around find to get all instances
    def all
      self.find({})
    end

    #Find method for searching in redis
    def find(args = {})
      args.symbolize_keys!
      out = []
      klass = self.name.constantize
      
      #is key specified directly? -> no needs of looking for other keys! -> faster
      if klass.valid_key?(args)
        if klass.exists?(args)
          data_args = Database.redis.hgetall(klass.generate_key(args))
          out << klass.new(args.merge(data_args).merge({:old_args => data_args})) 
        end
      else
        Database.redis.keys(klass.generate_key(args)).each do |key|
          data_args = Database.redis.hgetall(key)
          out << klass.new(args.merge(data_args).merge({:old_args => data_args}))
        end
      end
      out
    end

    #Find method for searching in redis
    def find_by_alias(alias_name, args = {})
      args.symbolize_keys!
      out = []
      klass = self.name.constantize
      
      #is key specified directly? -> no needs of looking for other keys! -> faster
      if klass.valid_alias_key?(alias_name, args)
        out << klass.get_by_alias(alias_name, args) if klass.alias_exists?(alias_name, args)
      else
        Database.redis.keys(klass.generate_alias_key(alias_name, args)).each do |key|
          out << klass.get_by_alias_key(key)
        end
      end
      out
    end

    #fastest method to get object from redis by getting it by arguments
    def get(args = {})
      args.symbolize_keys!
      klass = self.name.constantize
      if klass.valid_key?(args) && klass.exists?(args)
        data_args = Database.redis.hgetall(klass.generate_key(args))
        klass.new(args.merge(data_args).merge({:old_args => data_args})) 
      else
        nil
      end
    end

    #if you know redis key and would like to get object
    def get_by_redis_key(redis_key)
      if redis_key.is_a?(String) && Database.redis.exists(redis_key)
        if redis_key.include?("*")
          data_args = Database.redis.hgetall(redis_key)
          klass.new(data_args.merge({:old_args => data_args})) 
        else
          raise ArgumentError, "RedisKey for method get_by_redis_key can not contains '*'"
        end
      else
        nil
      end
    end 

    #fastest method to get object from redis by getting it by alias and arguments
    def get_by_alias(alias_name, args = {})
      args.symbolize_keys!
      klass = self.name.constantize
      if klass.valid_alias_key?(alias_name, args) && klass.alias_exists?(alias_name, args)
        key = Database.redis.get(klass.generate_alias_key(alias_name, args))
        if Database.redis.exists(key)
          data_args = Database.redis.hgetall(key)
          klass.new(args.merge(data_args).merge({:old_args => data_args})) 
        else
          nil
        end
      else
        nil
      end
    end    

    #fastest method to get object from redis by getting it by alias and arguments
    def get_by_alias_key(alias_key)
      klass = self.name.constantize
      if Database.redis.exists(alias_key)
        key = Database.redis.get(alias_key)
        if Database.redis.exists(key)
          klass.new(args.merge(Database.redis.hgetall(key)).merge({:old_args => key}))
        else
          nil
        end
      else
        nil
      end
    end    

  end
    
  module InstanceMethods
    
    def initialize(args={})
      args.symbolize_keys!
      #if old_args is specified, don't usi it in args hash
      if args[:old_args] && args[:old_args].size > 0 
        self.old_args = args.delete(:old_args).symbolize_keys
      end
      self.args = clear_args(args)
      return self
    end
    
    #Fixing some problems with saving nil into redis and clearing input arguments
    def clear_args(args)
      args.symbolize_keys!
      out_args = {}
      args.each do |key, value|
        if self.class.conf[:fields].keys.include?(key) #don't use arguments wich aren't specified in :fields 
          if value.nil? || value.to_s.size == 0 #change nil and zero length string into nil
            out_args[key] = nil 
          else
            out_args[key] = value
          end
        end
      end
      out_args
    end
    
    #validates required attributes
    def valid?
      @error = []
      self.class.conf[:required].each do |key|
        if !self.args.has_key?(key) || self.args[key].nil?
          @error.push("Required #{key}")
        end
      end
      @error.size == 0
    end
  
    #return error from validation
    def errors 
      @errors
    end
  
    #take all arguments and send them out
    def to_arg
      self.args.inject({}) do |output, item|
        output[item.first] = item.last.send(self.class.conf[:fields][item.first.to_sym])
        output
      end
    end
  
    #if this record exists in database
    def exists?
      Database.redis.exists(self.class.generate_key(self.args))
    end

    #remove record form database
    def destroy!
      if exists?
        #destroy main object
        Database.redis.del(redis_key) 
        destroy_aliases!
      end
    end

    #remove all aliases
    def destroy_aliases!
      #do it only if it is existing object!
      if self.old_args
        self.class.conf[:redis_aliases].each do |alias_name, fields|
          if self.class.valid_alias_key?(alias_name, self.old_args) && self.class.alias_exists?(alias_name, self.old_args)
            Database.redis.del(self.class.generate_alias_key(alias_name, self.old_args)) 
          end
        end
      end
    end
    
    #Method for creating aliases
    def create_aliases
      main_key = redis_key
      self.class.conf[:redis_aliases].each do |alias_name, fields|
        Database.redis.set(self.class.generate_alias_key(alias_name, self.args), main_key) if self.class.valid_alias_key?(alias_name, self.args)
      end
    end
  
    #get redis key for instance
    def redis_key
      self.class.generate_key(self.args)
    end
    
    #get redis key for instance alias
    def redis_alias_key(alias_name)
      self.class.generate_alias_key(alias_name, self.args)
    end
  
    #save method
    def save
      if valid?
        #generate key (possibly new)
        generated_key = redis_key
        Database.redis.rename(self.class.generate_key(self.old_args), generated_key) if self.old_args && generated_key != self.class.generate_key(self.old_args) && Database.redis.exists(self.class.generate_key(self.old_args))
        Database.redis.hmset(generated_key, *self.args.reject{|k,v| v.nil?}.inject([]){ |arr,kv| arr + [kv[0], kv[1].to_s]})
        
        #destroy aliases
        destroy_aliases!
        create_aliases
        #after save make new_key -> old_key
        self.old_args = self.args.clone
        return self
      else
        raise ArgumentError, @error.join(", ")
      end
    end
  end
end