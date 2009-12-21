# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

class Test::Unit::TestCase
  
  def assert_unique_fields_enforced(model, fields = [])
    assert_fields_have_error(model, fields, "activerecord_error_taken")
  end
  
  def assert_required_fields_enforced(model, fields = [])
    assert_fields_have_error(model, fields, "activerecord_error_blank")
  end
  
  def assert_fields_max_length_enforced(model, fields = [])
    assert_fields_have_error(model, fields, "activerecord_error_too_long")
  end
  
  def assert_fields_min_length_enforced(model, fields = [])
    assert_fields_have_error(model, fields, "activerecord_error_too_short")
  end
  
  def assert_fields_format_enforced(model, fields = [])
    assert_fields_have_error(model, fields, "activerecord_error_invalid")
  end
  
  def assert_fields_have_error(model, fields, message)
    fields.each do |field|
      assert_not_nil model.errors.on(field)
      assert model.errors.on(field).include?(message)
    end
  end
end