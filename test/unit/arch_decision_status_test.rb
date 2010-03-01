require File.dirname(__FILE__) + '/../test_helper'

class ArchDecisionStatusTest < ActiveSupport::TestCase
  fixtures :arch_decision_statuses

  def setup
    @valid = arch_decision_statuses(:valid)
  end

  def test_validity
    assert @valid.valid?
  end

  def test_required_fields
    invalid_status = ArchDecisionStatus.new
    assert !invalid_status.save
    fields = [:name, :position]
    assert_required_fields_enforced(invalid_status, fields)
  end

  def test_unique_fields
    invalid_status = ArchDecisionStatus.new(:name => @valid.name, :position => @valid.position)
    assert !invalid_status.save
    fields = [:name, :position]
    assert_unique_fields_enforced(invalid_status, fields)
  end
  
  def test_name_max_length
    valid_status = arch_decision_statuses(:valid_name_max_length)
    assert valid_status.valid?
  end
  
  def test_name_max_length_plus_one
    valid_status = arch_decision_statuses(:valid_name_max_length)
    invalid_status = ArchDecisionStatus.new(:name => valid_status.name + "a", :position => valid_status.position)
    assert !invalid_status.valid?
    fields = [:name]
    lengths = [ArchDecisionStatus::NAME_MAX_SIZE]
    assert_fields_max_length_enforced(invalid_status, fields, lengths)
  end
  
  def test_name_invalid_format
    invalid_status = arch_decision_statuses(:invalid_name_bad_format)
    assert !invalid_status.valid?
    fields = [:name]
    assert_fields_format_enforced(invalid_status, fields)
  end
  
  def test_name_valid_format
    valid_status = arch_decision_statuses(:valid_name_good_format)
    assert valid_status.valid?
  end

  def test_resolved
    status = ArchDecisionStatus.new(:name => "new", :is_resolved => true)
    assert status.resolved?
    status.is_resolved = false
    assert !status.resolved?
  end

  def test_complete
    status = ArchDecisionStatus.new(:name => "new", :is_complete => true)
    assert status.complete?
    status.is_complete = false
    assert !status.complete?
  end

  def test_irrelevant
    status = ArchDecisionStatus.new(:name => "new", :is_irrelevant => true)
    assert !status.relevant?
    status.is_irrelevant = false
    assert status.relevant?
  end

  # TODO: This test is failing because the "acts_as_list" feature sets the position to nil on destroy
  # Since the column is set to :null => false, this causes an error
  # Best solution: drop the constraint during a migration 
#  def test_destroy
#    id = @valid.id
#    ArchDecisionStatus.find(id).destroy
#    assert_nil ArchDecisionStatus.find_by_id(id)
#  end

end
