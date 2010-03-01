require File.dirname(__FILE__) + '/../test_helper'

class FactorStatusTest < ActiveSupport::TestCase
  fixtures :factor_statuses

  def setup
    @valid = factor_statuses(:valid)
  end

  def test_validity
    assert @valid.valid?
  end

  def test_name_required
    invalid_status = FactorStatus.new
    assert !invalid_status.save
    fields = [:name]
    assert_required_fields_enforced(invalid_status, fields)
  end

  def test_name_unique
    invalid_status = FactorStatus.new(:name => @valid.name)
    assert !invalid_status.save
    fields = [:name]
    assert_unique_fields_enforced(invalid_status, fields)
  end
  
  def test_name_max_length
    valid_status = factor_statuses(:valid_name_max_length)
    assert valid_status.valid?
  end
  
  def test_name_max_length_plus_one
    valid_status = factor_statuses(:valid_name_max_length)
    invalid_status = FactorStatus.new(:name => valid_status.name + "a", :position => valid_status.position)
    assert !invalid_status.valid?
    fields = [:name]
    lengths = [FactorStatus::NAME_MAX_SIZE]
    assert_fields_max_length_enforced(invalid_status, fields, lengths)
  end
  
  def test_name_invalid_format
    invalid_status = factor_statuses(:invalid_name_bad_format)
    assert !invalid_status.valid?
    fields = [:name]
    assert_fields_format_enforced(invalid_status, fields)
  end
  
  def test_name_valid_format
    valid_status = factor_statuses(:valid_name_good_format)
    assert valid_status.valid?
  end
  
  def test_destroy
    id = @valid.id
    FactorStatus.find(id).destroy
    assert_nil FactorStatus.find_by_id(id)
  end


end
