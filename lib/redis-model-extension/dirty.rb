# -*- encoding : utf-8 -*-
module RedisModelExtension

  # == Dirty
  # module for easier detection of changed attributes
  #
  # if you want it in your model include it after RedisModelExtension, i.e.
  #
  #  class MyModel
  #    include RedisModelExtension
  #    include RedisModelExtension::Dirty
  #  end
  module Dirty
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Dirty
    end

    def attribute=(name, value)
      attribute_will_change!(name) unless value == attribute(name)
      super
    end

    def save
      if result = super
        @previously_changed = changes
        @changed_attributes.clear
      end
      result
    end

    module ClassMethods
      # hook to reset changed attributes, when load by .find or .get
      def new_by_key(key)
        new_instance = super
        new_instance.changed_attributes.clear
        new_instance
      end
    end

  end
end
