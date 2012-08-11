# -*- encoding : utf-8 -*-
module RedisModelExtension
  module InstanceMethods

    # validates required attributes
    def valid?
      @error ||= []
      redis_validation_config.each do |key|
        @error.push("Required #{key}") unless self.send("#{key}?")
      end
      @error.size == 0
    end

    #return error from validation
    def error
      @error ||= []
    end
    
    #always forgotting which one to use :)
    alias :errors :error    

  end
end