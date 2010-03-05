require File.dirname(__FILE__) + '/../test_helper'
require 'arch_decision_discussions_controller'

# Re-raise errors caught by the controller.
class ArchDecisionDiscussionsController; def rescue_action(e) raise e end; end

class ArchDecisionDiscussionsControllerTest < ActionController::TestCase

  fixtures :projects,
           :users,
           :roles,
           :arch_decisions,
           :factors,
           :strategies,
           :arch_decision_discussions
  
  def setup
    @ad = arch_decisions(:valid)
    @controller = ArchDecisionDiscussionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    enable_ad_module(@ad.project)
    setup_user_with_permissions(@request)
    Setting.default_language = 'en'
  end

  def test_new_ad_discussion
    expected_counts = get_counts
    post :new, 
          :project_id => 1, 
          :arch_decision_id => @ad.id, 
          :discussion => {:subject => "New discussion", :content => "New content"}
    assert_redirected_to :controller => "arch_decisions", :action => "show"
    #assert_equal 'Post was successfully created.', flash[:notice]    assert_not_nil assigns(:project)
    assert_not_nil assigns(:arch_decision)
    add_counts expected_counts, :arch_decisions, 1
    assert_counts expected_counts
  end
 
  def test_new_factor_discussion
    expected_counts = get_counts
    factor = factors(:valid)
    post :new, 
          :project_id => 1, 
          :factor_id => factor.id, 
          :discussion => {:subject => "New discussion", :content => "New content"}
    assert_redirected_to :controller => "factors", :action => "show"
    #assert_equal 'Post was successfully created.', flash[:notice]    assert_not_nil assigns(:project)
    assert_not_nil assigns(:factor)
    add_counts expected_counts, :factors, 1
    assert_counts expected_counts
  end
  
  def test_new_ad_factor_discussion
    expected_counts = get_counts
    factor = factors(:valid_2)
    post :new, 
          :project_id => 1, 
          :factor_id => factor.id, 
          :discussion => {:subject => "New discussion", :content => "New content"}
    assert_redirected_to :controller => "factors", :action => "show"
    #assert_equal 'Post was successfully created.', flash[:notice]    assert_not_nil assigns(:project)
    assert_not_nil assigns(:factor)
    add_counts expected_counts, :factors, 1
    assert_counts expected_counts
  end
  
  def test_new_ad_factor_discussion_no_ad
    expected_counts = get_counts
    factor = factors(:valid_ad_no_ad)
    post :new, 
          :project_id => 1, 
          :factor_id => factor.id, 
          :discussion => {:subject => "New discussion", :content => "New content"}
    assert_redirected_to :controller => "factors", :action => "show"
    #assert_equal 'Post was successfully created.', flash[:notice]    assert_not_nil assigns(:project)
    assert_not_nil assigns(:factor)
    add_counts expected_counts, :factors, 1
    assert_counts expected_counts
  end
  
  def test_new_strategy_discussion
    expected_counts = get_counts
    strategy = strategies(:valid)
    post :new, 
          :project_id => 1, 
          :arch_decision_id => @ad.id, 
          :strategy_id => strategy.id,
          :discussion => {:subject => "New discussion", :content => "New content"}
    assert_redirected_to :controller => "strategies", :action => "show"
    #assert_equal 'Post was successfully created.', flash[:notice]    assert_not_nil assigns(:project)
    assert_not_nil assigns(:strategy)
    add_counts expected_counts, :strategies, 1
    assert_counts expected_counts
  end

  def test_new_ad_discussion_no_perms
    setup_user_no_permissions(@request)
    post :new, 
          :project_id => 1, 
          :arch_decision_id => @ad.id, 
          :discussion => {:subject => "New discussion", :content => "New content"}
    assert_response 403
  end

  def test_new_factor_discussion_no_perms
    setup_user_no_permissions(@request)
    factor = factors(:valid)
    post :new, 
          :project_id => 1, 
          :factor_id => factor.id, 
          :discussion => {:subject => "New discussion", :content => "New content"}
    assert_response 403
  end

  def test_new_strategy_discussion_no_perms
    setup_user_no_permissions(@request)
    strategy = strategies(:valid)
    post :new, 
          :project_id => 1, 
          :arch_decision_id => @ad.id, 
          :strategy_id => strategy.id,
          :discussion => {:subject => "New discussion", :content => "New content"}
    assert_response 403
  end

  private
  
  def get_counts
    counts = {
      :total => ArchDecisionDiscussion.find(:all).size, 
      :arch_decisions => ArchDecisionDiscussion.find(:all, :conditions => "NOT arch_decision_id IS NULL").size, 
      :factors => ArchDecisionDiscussion.find(:all, :conditions => "NOT factor_id IS NULL").size,  
      :strategies => ArchDecisionDiscussion.find(:all, :conditions => "NOT strategy_id IS NULL").size 
    }
  end
  
  def add_counts(counts, type, amount)
    counts[type] += amount
    counts[:total] += amount
  end
  
  def assert_counts(expected_counts)
    actual_counts = get_counts
    actual_counts.each{ |key, val| assert_equal expected_counts[key], val, "Count for #{key} did not match"}
  end
  
end
