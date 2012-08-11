# -*- encoding : utf-8 -*-
require 'helper'
class StringToBoolTest < Test::Unit::TestCase
  context "String to_bool" do

    should "return true" do
      assert "true".to_bool, "true"
      assert "1".to_bool, "1"
      assert "t".to_bool, "t"
      assert "y".to_bool, "y"
      assert "yes".to_bool, "yes"
    end

    should "return false" do
      assert ! "false".to_bool, "false"
      assert ! "0".to_bool, "0"
      assert ! "f".to_bool, "f"
      assert ! "no".to_bool, "no"
      assert ! "n".to_bool, "n"
      assert ! "".to_bool, "blank string"
    end

    should "raise exception on unknown" do
      assert_raises ArgumentError do
        "unknown string".to_bool
      end
    end

  end
end
