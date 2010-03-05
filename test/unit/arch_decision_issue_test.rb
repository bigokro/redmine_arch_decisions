require File.dirname(__FILE__) + '/../test_helper'

class ArchDecisionIssueTest < ActiveSupport::TestCase
  fixtures :arch_decision_issues, :arch_decisions, :issues

  def setup
    @valid = arch_decision_issues(:valid_001)
  end

  def test_validity
    assert @valid.valid?
  end

  def test_destroy
    id = @valid.id
    ArchDecisionIssue.find(id).destroy
    assert_nil ArchDecisionIssue.find_by_id(id)
  end
  
  def test_destroy_issue_survives
    id = @valid.id
    issid = issues(:issues_001).id
    ArchDecisionIssue.find(id).destroy
    assert_not_nil Issue.find_by_id(issid)
  end
  
  def test_destroy_arch_decision_survives
    id = @valid.id
    adid = arch_decisions(:valid).id
    ArchDecisionIssue.find(id).destroy
    assert_not_nil ArchDecision.find_by_id(adid)
  end
  
end
