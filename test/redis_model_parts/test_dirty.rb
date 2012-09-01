# -*- encoding : utf-8 -*-
require 'helper'
class DirtyTest < Test::Unit::TestCase
  context 'Dirty' do
    setup do
      @time = Time.now
      @args = {
        :first_field => 'foo',
        :second_field => true,
        :third_field => 100,
      }
      @test_model = WithDirty.create(@args)
    end

    context 'after initialize' do
      should 'be dirty' do
        @test_model = WithDirty.new(@args)

        assert @test_model.changed?
        assert_same_elements @args.keys, @test_model.changed

        @test_model.changes.each do |key,value|
          assert value[0].nil?
          assert_equal @args[key], value[1]
        end
      end
    end

    context 'after load' do
      should 'be clean' do
        @model = WithDirty.get(first_field: 'foo')

        refute @model.changed?
        refute @model.changed.any?
      end

      context '& after modifying' do
        setup do
          @model = WithDirty.get(first_field: 'foo')
          @model.first_field = 'bar'
        end

        should 'be dirty' do
          assert @model.changed?
          assert_equal ['first_field'], @model.changed
          assert @model.first_field_changed?
          assert_equal ['foo', 'bar'], @model.first_field_change
          assert_equal 'foo', @model.first_field_was
        end

        context ' & after save' do
          should 'be clean once again' do
            @model.save
            refute @model.changed?
            refute @model.changed.any?

            # just to be sure it successfully saved itself
            assert WithDirty.get(first_field: 'bar')
          end
        end
      end

    end
  end
end
