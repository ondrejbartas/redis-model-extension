# -*- encoding : utf-8 -*-
require 'helper'
class HooksTest < Test::Unit::TestCase
  context "Hooks" do

    should "fire before_create hooks" do
      WithCallbacks.any_instance.expects(:before_create_method)

      WithCallbacks.create name: 'Callbacks'
    end

    should "fire both before_create and before_save hooks if defined" do
      WithCallbacks.any_instance.expects(:before_create_method)
      WithCallbacks.any_instance.expects(:before_save_method)
      WithCallbacks.any_instance.expects(:after_save_method)

      WithCallbacks.create name: 'Callbacks'
    end

    should "fire before_save hooks" do
      article = WithCallbacks.new name: 'Callbacks'
      article.expects(:before_save_method)
      article.expects(:after_save_method)
      article.expects(:before_create_method)
      article.save
    end

    should "fire before_destroy hooks" do
      article = WithCallbacks.new name: 'Callbacks'
      article.save
      article.destroy

      assert article.instance_variable_get(:@destroyed_flag), "should have destroyed flag"
    end
  end
end