require File.dirname(__FILE__) + '/../test_helper'

class ArchDecisionDiscussionTest < ActiveSupport::TestCase
  fixtures :arch_decision_discussions, :arch_decisions, :factors, :strategies

  def test_validity
    add1 = arch_decision_discussions(:arch_decision_discussion_1)
    assert add1.save
  end

  def test_subject_max_length
    valid_subject_max_length = arch_decision_discussions(:valid_subject_max_length)
    assert valid_subject_max_length.valid?
  end

  def test_summary_max_length_plus_one
    valid_add = arch_decision_discussions(:valid_subject_max_length)
    invalid_add = valid_add.clone
    invalid_add.subject += "a"
    assert !invalid_add.save
    fields = [:subject]
    lengths = [ArchDecisionDiscussion::SUBJECT_MAX_SIZE]
    assert_fields_max_length_enforced(invalid_add, fields, lengths)
  end
  
  def test_required_fields
    invalid_add = ArchDecisionDiscussion.new
    assert !invalid_add.save
    fields = [:subject, :content, :created_by]
    assert_required_fields_enforced(invalid_add, fields)
  end
  
  def test_association_required
    invalid_add = arch_decision_discussions(:arch_decision_discussion_1).clone
    invalid_add.arch_decision = nil
    assert !invalid_add.save
    assert invalid_add.errors.on_base.include?(:error_discussion_parents_nil.to_s),
            "Error messages don't include '" + :error_discussion_parents_nil.to_s + "'. Messages: " + invalid_add.errors.on_base.to_s 
  end

  def test_destroy
    id = arch_decision_discussions(:arch_decision_discussion_1).id
    ArchDecisionDiscussion.find(id).destroy
    assert_nil ArchDecisionDiscussion.find_by_id(id)
  end
  
  def test_destroy_arch_decision_survives
    id = arch_decision_discussions(:arch_decision_discussion_1).id
    adid = arch_decisions(:valid).id
    ArchDecisionDiscussion.find(id).destroy
    assert_not_nil ArchDecision.find_by_id(adid)
  end
  
  def test_destroy_factor_survives
    id = arch_decision_discussions(:factor_discussion_1).id
    fid = factors(:valid).id
    ArchDecisionDiscussion.find(id).destroy
    assert_not_nil Factor.find_by_id(fid)
  end
  
  def test_destroy_arch_decision_survives
    id = arch_decision_discussions(:strategy_discussion_1).id
    sid = strategies(:valid).id
    ArchDecisionDiscussion.find(id).destroy
    assert_not_nil Strategy.find_by_id(sid)
  end
  
  def test_parent
    add1 = arch_decision_discussions(:arch_decision_discussion_1)
    fd1 = arch_decision_discussions(:factor_discussion_1)
    sd1 = arch_decision_discussions(:strategy_discussion_1)
    assert_equal add1.arch_decision, add1.parent
    assert_equal fd1.factor, fd1.parent
    assert_equal sd1.strategy, sd1.parent
  end
  
  def test_type
    add1 = arch_decision_discussions(:arch_decision_discussion_1)
    fd1 = arch_decision_discussions(:factor_discussion_1)
    sd1 = arch_decision_discussions(:strategy_discussion_1)
    assert_equal "Arch Decision Discussion", add1.type
    assert_equal "Factor Discussion", fd1.type
    assert_equal "Strategy Discussion", sd1.type
  end
  
  def test_parent_type
    add1 = arch_decision_discussions(:arch_decision_discussion_1)
    fd1 = arch_decision_discussions(:factor_discussion_1)
    sd1 = arch_decision_discussions(:strategy_discussion_1)
    assert_equal "Arch Decision", add1.parent_type
    assert_equal "Factor", fd1.parent_type
    assert_equal "Strategy", sd1.parent_type
  end
  
  def test_project
    add1 = arch_decision_discussions(:arch_decision_discussion_1)
    fd1 = arch_decision_discussions(:factor_discussion_1)
    sd1 = arch_decision_discussions(:strategy_discussion_1)
    assert_equal add1.project, add1.parent.project
    assert_equal fd1.project, fd1.parent.project
    assert_equal sd1.project, sd1.parent.project
  end
  
  # TODO: Test recipients
  # TODO: Test watcher_recipients
  
end
