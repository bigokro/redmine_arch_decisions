require File.dirname(__FILE__) + '/../test_helper'

class FactorTest < ActiveSupport::TestCase
  fixtures :factors, 
            :arch_decisions, 
            :arch_decision_discussions, 
            :arch_decision_factors,
            :projects

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
    lengths = [Factor::SUMMARY_MAX_SIZE]
    assert_fields_max_length_enforced(invalid_factor, fields, lengths)
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

  def test_scope_global
    factor = @valid_factor.clone
    factor.scope = Factor::SCOPE_GLOBAL
    factor.project = nil
    assert factor.valid?
  end
  
  def test_scope_global_multiple_projects
    factor = @valid_factor.clone
    factor.scope = Factor::SCOPE_GLOBAL
    factor.project = nil
    ad = arch_decisions(:valid)
    factor.arch_decisions << ad
    ad2 = ad.clone
    ad2.project = projects(:projects_002)
    factor.arch_decisions << ad2
    assert factor.valid?
  end
  
  def test_scope_global_invalid
    factor = @valid_factor.clone
    factor.scope = Factor::SCOPE_GLOBAL
    factor.project = projects(:projects_001)
    assert !factor.valid?
  end
  
  def test_scope_project
    factor = @valid_factor.clone
    factor.scope = Factor::SCOPE_PROJECT
    factor.project = projects(:projects_001)
    assert factor.valid?
  end
  
  def test_scope_project_nil
    factor = @valid_factor.clone
    factor.scope = Factor::SCOPE_PROJECT
    factor.project = nil
    assert !factor.valid?
  end
  
  def test_scope_project_ad_project_mismatch
    factor = @valid_factor.clone
    factor.scope = Factor::SCOPE_PROJECT
    factor.project = projects(:projects_001)
    ad = arch_decisions(:valid)
    factor.arch_decisions << ad
    ad2 = ad.clone
    ad2.project = projects(:projects_002)
    factor.arch_decisions << ad2
    assert !factor.valid?
  end
  
  def test_scope_project_ad_project_matches
    project = projects(:projects_001)
    factor = @valid_factor.clone
    factor.scope = Factor::SCOPE_PROJECT
    factor.project = project
    ad = arch_decisions(:valid)
    ad.project = project
    factor.arch_decisions << ad
    ad2 = ad.clone
    ad2.project = project
    factor.arch_decisions << ad2
    assert factor.valid?
  end
  
  def test_scope_ad
    factor = @valid_factor.clone
    factor.scope = Factor::SCOPE_ARCH_DECISION
    factor.project = projects(:projects_001)
    assert factor.valid?
  end
  
  def test_scope_ad_project_nil
    factor = @valid_factor.clone
    factor.scope = Factor::SCOPE_ARCH_DECISION
    factor.project = nil
    assert !factor.valid?
  end
  
  def test_scope_ad_multiple_ads
    factor = @valid_factor.clone
    project = projects(:projects_001)
    factor.scope = Factor::SCOPE_ARCH_DECISION
    factor.project = project
    ad = arch_decisions(:valid)
    ad.project = project
    factor.arch_decisions << ad
    ad2 = arch_decisions(:valid_summary_max_length)
    ad2.project = project
    factor.arch_decisions << ad2
    assert !factor.valid?
  end
  
  def test_scope_ad_no_ads
    factor = @valid_factor.clone
    factor.scope = Factor::SCOPE_ARCH_DECISION
    factor.project = projects(:projects_001)
    factor.arch_decisions = []
    assert factor.valid?
  end

  def test_scope_name
    factor = @valid_factor
    factor.scope = Factor::SCOPE_GLOBAL
    factor.project = projects(:projects_001)
    assert_equal "Global", factor.scope_name
    factor.scope = Factor::SCOPE_PROJECT
    assert_equal "Project", factor.scope_name
    factor.scope = Factor::SCOPE_ARCH_DECISION
    assert_equal "Arch Decision", factor.scope_name
  end
  
  def test_scope_invalid
    factor = @valid_factor.clone
    factor.scope = "Invalid"
    factor.project = nil
    assert !factor.valid?
  end
  

end
