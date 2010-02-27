require File.dirname(__FILE__) + '/../test_helper'

class ArchDecisionFactorTest < ActiveSupport::TestCase
  fixtures :arch_decision_factors, :arch_decisions, :factors

  def setup
    @valid = arch_decision_factors(:valid_valid)
  end

  def test_validity
    assert @valid.valid?
  end

  def test_destroy
    id = @valid.id
    ArchDecisionFactor.find(id).destroy
    assert_nil ArchDecisionFactor.find_by_id(id)
  end
  
  def test_destroy_factor_survives
    id = @valid.id
    fid = factors(:valid).id
    ArchDecisionFactor.find(id).destroy
    assert_not_nil Factor.find_by_id(fid)
  end
  
  def test_destroy_arch_decision_survives
    id = @valid.id
    adid = arch_decisions(:valid).id
    ArchDecisionFactor.find(id).destroy
    assert_not_nil ArchDecision.find_by_id(adid)
  end
  
end
