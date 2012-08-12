# -*- encoding : utf-8 -*-

#bad naming in past, will be removed
module RedisModel

  #include all needed modules directly into main class
  def self.included(base) 
    puts "WARNING: Using include RedisModel is deprecated and will be removed soon"
    base.class_eval do  
      include RedisModelExtension
    end
  end

end
