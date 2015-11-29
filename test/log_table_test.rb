require 'test_helper'

class SomeModel < ActiveRecord::Base
  include LogTable

  def self.column_names
    %q(id name email)
  end

  add_log_trigger
end

class LogTableTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::LogTable::VERSION
  end

  def test_that_add_log_trigger_class_method_is_added
    assert SomeModel.methods.include?(:add_log_trigger)
  end

  def test_that_triggers_will_be_added
    # Run migration

    # Check that the migration contains an add_trigger
  end
end
