require File.dirname(__FILE__) + '/../test_helper'

class StrategyTest < ActiveSupport::TestCase
  fixtures :strategies, :arch_decisions, :arch_decision_discussions

  def setup
    @valid = strategies(:valid)
  end

  def test_validity
    assert @valid.valid?
  end

  def test_rejected
    assert !@valid.rejected?
    @valid.is_rejected = true
    assert @valid.rejected?
  end

  def test_short_name_max_length
    valid_short_name_max_length = strategies(:valid_short_name_max_length)
    assert valid_short_name_max_length.valid?
  end

  def test_short_name_max_length_plus_one
    valid = strategies(:valid_short_name_max_length)
    invalid = valid.clone
    invalid.short_name += "a"
    assert !invalid.save
    fields = [:short_name]
    lengths = [Strategy::SHORT_NAME_MAX_SIZE]
    assert_fields_max_length_enforced(invalid, fields, lengths)
  end
  
  def test_required_fields
    invalid = Strategy.new
    assert !invalid.save
    fields = [:short_name, :arch_decision, :created_by, :updated_by]
    assert_required_fields_enforced(invalid, fields)
  end
  
  def test_destroy
    id = @valid.id
    Strategy.find(id).destroy
    assert_nil Strategy.find_by_id(id)
  end
  
  def test_destroy_arch_decision_survives
    id = @valid.id
    adid = arch_decisions(:valid).id
    Strategy.find(id).destroy
    assert_not_nil ArchDecision.find_by_id(adid)
  end
  
  def test_destroy_discussions_die
    id = @valid.id
    did = arch_decision_discussions(:strategy_discussion_1).id
    Strategy.find(id).destroy
    assert_nil ArchDecisionDiscussion.find_by_id(did)
  end
  
end
