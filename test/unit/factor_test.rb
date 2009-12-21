require File.dirname(__FILE__) + '/../test_helper'

class FactorTest < Test::Unit::TestCase
  fixtures :factors, :arch_decisions, :arch_decision_discussions, :arch_decision_factors

  def setup
    @valid_factor = factors(:valid)
  end

  # This Factor should be valid by construction.
  def test_factor_validity
    assert @valid_factor.valid?
  end

  def test_summary_max_length
    valid_summary_max_length = factors(:valid_summary_max_length)
    assert valid_summary_max_length.valid?
  end

  def test_summary_max_length_plus_one
    valid_factor = factors(:valid_summary_max_length)
    invalid_factor = valid_factor.clone
    invalid_factor.summary += "a"
    assert !invalid_factor.save
    fields = [:summary]
    assert_fields_max_length_enforced(invalid_factor, fields)
  end
  
  def test_required_fields
    invalid_factor = @valid_factor.clone
    invalid_factor.summary = nil
    invalid_factor.status = nil
    assert !invalid_factor.save
    fields = [:summary, :status]
    assert_required_fields_enforced(invalid_factor, fields)
  end
  
  def test_refuted_method
    assert !@valid_factor.refuted?
    @valid_factor.status = FactorStatus.new(:name => "Refuted")
    assert @valid_factor.refuted?
  end

  def test_destroy
    id = @valid_factor.id
    Factor.find(id).destroy
    assert_nil Factor.find_by_id(id)
  end

  def test_destroy_discussions_die
    id = @valid_factor.id
    did = arch_decision_discussions(:factor_discussion_1).id
    Factor.find(id).destroy
    assert_nil ArchDecisionDiscussion.find_by_id(did)
  end
  
  def test_destroy_arch_decisions_survive
    id = @valid_factor.id
    adid = arch_decisions(:valid).id
    adfid = arch_decision_factors(:valid_valid).id
    Factor.find(id).destroy
    assert_nil ArchDecisionFactor.find_by_id(adfid)
    assert_not_nil ArchDecision.find_by_id(adid)
  end
  
end
