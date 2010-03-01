require File.dirname(__FILE__) + '/../test_helper'

class FactorsControllerTest < ActionController::TestCase

  fixtures :projects,
           :factors,
           :arch_decisions,
           :users,
           :members,
           :roles,
           :member_roles,
           :issues
           
  def setup
    @factor = factors(:valid)
    @project = projects(:projects_001)
    @controller = FactorsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    enable_ad_module(@project)
    setup_user_with_permissions(@request)
    Setting.default_language = 'en'
  end
  
  def test_index
    # TODO - test filters, pagination, sorting
    get :index, :project_id => @project.id
    assert_response :success
    assert_template 'index'
    assert_index_lists_factor factors(:valid)
    assert_index_lists_factor factors(:valid_2)
    assert_index_lists_factor factors(:valid_3)
    assert_index_lists_factor factors(:valid_4)
    assert_index_lists_factor factors(:valid_ad_no_ad)
    assert_index_lists_factor factors(:valid_global)
    assert_index_does_not_list_factor factors(:valid_other_project)
    assert_index_does_not_list_factor factors(:valid_ad_other_project)
  end

  def test_index_no_perms
    setup_user_no_permissions(@request)
    get :index, :project_id => @project.id
    assert_response 403
  end

  def test_index_popup
    # TODO - test filters, pagination, sorting
    arch_decision = arch_decisions(:valid_summary_max_length)
    get :index, :project_id => @project.id, :arch_decision_id => arch_decision.id, :mode => 'popup'
    assert_response :success
    assert_template 'index'
    assert_index_lists_factor factors(:valid_global)
    assert_index_lists_factor factors(:valid_ad_no_ad)
    assert_index_does_not_list_factor factors(:valid)
    assert_index_does_not_list_factor factors(:valid_2)
    assert_index_does_not_list_factor factors(:valid_3)
    assert_index_does_not_list_factor factors(:valid_4)
    assert_index_does_not_list_factor factors(:valid_other_project)
    assert_index_does_not_list_factor factors(:valid_ad_other_project)
  end

  def test_new
    get :new, :project_id => @project.id
    assert_response :success
    assert_template 'new'
    statuses = assigns(:factor_statuses)
    assert_not_nil statuses
    assert_select "form[action=/projects/#{@project.identifier}/factors/new]" do
      assert_select 'input#factor_summary'
      assert_select 'textarea#factor_details'
      assert_select 'textarea#factor_evidence'
      assert_select 'select#factor_scope'
      assert_select 'select#factor_status_id'
    end
    # TODO: assert that submit creates a new Factor
  end
  
  def test_new_no_perms
    setup_user_no_permissions(@request)
    get :new, :project_id => @project.id
    assert_response 403
  end
  
  def test_edit
    get :edit, :project_id => @project.id, :id => @factor.id
    assert_response :success
    assert_template 'edit'
    statuses = assigns(:factor_statuses)
    assert_not_nil statuses
    assert_select "form[action=/projects/#{@project.identifier}/factors/edit/#{@factor.id}]" do
      assert_select 'input#factor_summary'
      assert_select 'textarea#factor_details'
      assert_select 'textarea#factor_evidence'
      assert_select 'select#factor_status_id'
      assert_select 'select#factor_scope'
    end
    # TODO: assert that submit udpdates Factor
  end
  
  def test_edit_no_perms
    setup_user_no_permissions(@request)
    get :edit, :project_id => @project.id, :id => @factor.id
    assert_response 403
  end

  private
  
  #Handles both regular and popup mode
  def assert_index_lists_factor(factor)
    assert_select "a[href=?]", 
                    /(\/projects\/#{@project.identifier}\/factors\/show\/#{factor.id}|\/projects\/#{@project.id}\/arch_decisions\/add_factor\/[0-9]+\/#{factor.id})/, 
                    true,
                    "Can't find factor '#{factor.summary}'"
  end
  
  #Handles both regular and popup mode
  def assert_index_does_not_list_factor(factor)
    assert_select "a[href=?]", 
                    /(\/projects\/#{@project.identifier}\/factors\/show\/#{factor.id}|\/projects\/#{@project.id}\/arch_decisions\/add_factor\/[0-9]+\/#{factor.id})/, 
                    false, 
                    "Unexpectedly found factor '#{factor.summary}'"
  end
end
