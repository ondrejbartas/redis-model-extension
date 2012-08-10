module RedisModel
  module InstanceMethods

    #validates required attributes
    def valid?
      @error ||= []
      self.class.conf[:required].each do |key|
        if !self.args.has_key?(key) || self.args[key].nil?
          @error.push("Required #{key}")
        end
      end
      @error.size == 0
    end

    #return error from validation
    def error
      @error ||= []
    end
  
    #return error from validation
    def errors 
      @error ||= []
    end
    
  end
end