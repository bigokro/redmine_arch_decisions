require File.dirname(__FILE__) + '/../test_helper'
require 'arch_decisions_controller'

# Re-raise errors caught by the controller.
class ArchDecisionsController; def rescue_action(e) raise e end; end

class ArchDecisionsControllerTest < ActionController::TestCase

  fixtures :projects,
           :users,
           :arch_decisions,
           :arch_decision_statuses,
           :factors,
           :members,
           :roles,
           :issues,
           :issue_statuses
           
  def setup
    @ad = arch_decisions(:valid)
    @controller = ArchDecisionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    enable_ad_module(@ad.project)
    setup_user_with_permissions(@request)
    Setting.default_language = 'en'
  end

  def test_index
    get :index, :project_id => 1
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:arch_decisions)
    assert_not_nil assigns(:arch_decision_count)
    assert_not_nil assigns(:arch_decision_pages)
    assert_tag :tag => 'a', :content => @ad.summary
    assert_tag :tag => 'a', :content => 'New Arch Decision', :attributes => { :href => /arch_decisions\/new/ }
  end

  def test_index_no_perms
    setup_user_no_permissions(@request)
    get :index, :project_id => @ad.project.id
    assert_response 403
  end
  
  def test_index_no_project
    begin
      get :index
      assert false
    rescue
      #This is what we want
    end
  end

  def test_index_default_sorting
    get :index, :project_id => 1
    assert_response :success
    arch_decisions = assigns(:arch_decisions)
    ad2 = arch_decisions(:valid_summary_max_length)
    assert_equal @ad, arch_decisions[@ad.id > ad2.id ? 0 : 1]
    assert_equal ad2, arch_decisions[@ad.id > ad2.id ? 1 : 0]
    assert_tag :tag => 'a', :content => '#', :attributes => { :href => /sort=id$/ }
    assert_tag :tag => 'a', :content => 'Status', :attributes => { :href => /sort=status_id%2Cid%3Adesc$/ }
    assert_tag :tag => 'a', :content => 'Arch Decision', :attributes => { :href => /sort=summary%2Cid%3Adesc$/ }
    assert_tag :tag => 'a', :content => 'Assigned to', :attributes => { :href => /sort=assigned_to_id%2Cid%3Adesc$/ }
    assert_tag :tag => 'a', :content => 'Updated on', :attributes => { :href => /sort=updated_on%3Adesc%2Cid%3Adesc$/ }
    assert_tag :tag => 'a', :content => 'Delete', :attributes => { :href => /arch_decisions\/destroy/ }
  end

  def test_index_sort_id_asc
    get :index, :project_id => 1, :sort => 'id'
    assert_response :success
    arch_decisions = assigns(:arch_decisions)
    ad2 = arch_decisions(:valid_summary_max_length)
    assert_equal @ad, arch_decisions[@ad.id > ad2.id ? 1 : 0]
    assert_equal ad2, arch_decisions[@ad.id > ad2.id ? 0 : 1]
    assert_tag :tag => 'a', :content => '#', :attributes => { :href => /sort=id%3Adesc$/ }
  end

  def test_index_paging_default
    generate_test_ads
    get :index, :project_id => 1
    assert_response :success
    arch_decisions = assigns(:arch_decisions)
    assert_equal 25, arch_decisions.size
    assert_no_tag :tag => 'a', :content => '25'
    assert_tag :tag => 'a', :content => '50', :attributes => { :href => /per_page=50/ }
    assert_tag :tag => 'a', :content => '100', :attributes => { :href => /per_page=100/ }
    assert_no_tag :tag => 'a', :content => '1'
    assert_tag :tag => 'a', :content => '2', :attributes => { :href => /page=2/ }
  end

  def test_index_paging_second_page
    generate_test_ads
    get :index, :project_id => 1, :page => 2
    assert_response :success
    arch_decisions = assigns(:arch_decisions)
    assert_equal 2, arch_decisions.size
    assert_no_tag :tag => 'a', :content => '25'
    assert_tag :tag => 'a', :content => '50', :attributes => { :href => /per_page=50/ }
    assert_tag :tag => 'a', :content => '100', :attributes => { :href => /per_page=100/ }
    assert_tag :tag => 'a', :content => '1', :attributes => { :href => /page=1/ }
    assert_no_tag :tag => 'a', :content => '2'
  end

  def test_index_paging_50_per_page
    generate_test_ads
    get :index, :project_id => 1, :per_page => 50
    assert_response :success
    arch_decisions = assigns(:arch_decisions)
    assert_equal 27, arch_decisions.size
    assert_tag :tag => 'a', :content => '25', :attributes => { :href => /per_page=25/ }
    assert_no_tag :tag => 'a', :content => '50'
    assert_tag :tag => 'a', :content => '100', :attributes => { :href => /per_page=100/ }
    assert_no_tag :tag => 'a', :content => '1'
    assert_no_tag :tag => 'a', :content => '2'
  end

  def test_index_filters_on_id
    generate_test_ads
    get :index, :project_id => 1, :summary => @ad.id.to_s
    assert_response :success
    arch_decisions = assigns(:arch_decisions)
    assert_equal 1, arch_decisions.size
    assert_equal @ad, arch_decisions[0]
  end

  def test_index_filters_on_summary
    generate_test_ads
    get :index, :project_id => 1, :summary => @ad.summary
    assert_response :success
    arch_decisions = assigns(:arch_decisions)
    assert_equal 1, arch_decisions.size
    assert_equal @ad, arch_decisions[0]
  end

  def test_index_filters_multiple_results
    generate_test_ads 5
    get :index, :project_id => 1, :summary => "Generated test"
    assert_response :success
    arch_decisions = assigns(:arch_decisions)
    assert_equal 5, arch_decisions.size
    assert !arch_decisions.include?(@ad)
  end

  def test_index_filters_paged_results
    generate_test_ads 50
    get :index, :project_id => 1, :summary => "Generated test"
    assert_response :success
    arch_decisions = assigns(:arch_decisions)
    assert_equal 25, arch_decisions.size
    assert !arch_decisions.include?(@ad)
  end

  def test_index_filters_no_results
    generate_test_ads
    get :index, :project_id => @ad.project.id, :summary => 'blahblahblah no results'
    assert_response :success
    arch_decisions = assigns(:arch_decisions)
    assert_equal 0, arch_decisions.size
  end

  def test_show
    get :show, :project_id => @ad.project.id, :id => @ad.id
    assert_response :success
    assert_template 'show'
    ad = assigns(:arch_decision)
    project = assigns(:project)
    factor_statuses = assigns(:factor_statuses)
    discussions = assigns(:discussions)
    discussion = assigns(:discussion)
    assert_equal @ad, ad
    assert_equal @ad.project, project
    assert_not_nil factor_statuses
    assert_equal @ad.discussions, discussions
    assert_not_nil discussion
    assert_equal "Re: " + @ad.summary, discussion.subject
    assert_tag :tag => 'small', :content => '(drag to reorder)'
    assert_tag :tag => 'a', 
                :content => 'Edit', 
                :attributes => { :href => /#{@ad.project.identifier}\/arch_decisions\/edit\/#{@ad.id}/ }
  end

  def test_show_no_perms
    setup_user_no_permissions(@request)
    get :show, :project_id => @ad.project.id, :id => @ad.id
    assert_response 403
  end
  
  def test_show_view_perms_only
    setup_user_view_permissions_only(@request)
    get :show, :project_id => @ad.project.id, :id => @ad.id
    assert_response :success
    assert_template 'show'
    ad = assigns(:arch_decision)
    project = assigns(:project)
    factor_statuses = assigns(:factor_statuses)
    discussions = assigns(:discussions)
    discussion = assigns(:discussion)
    assert_equal @ad, ad
    assert_equal @ad.project, project
    assert_not_nil factor_statuses
    assert_equal @ad.discussions, discussions
    assert_no_tag :tag => 'a', :content => 'Edit'
    assert_no_tag :tag => 'a', :content => 'New <u>F</u>actor'
    assert_no_tag :tag => 'a', :content => '<u>A</u>dd Factor'
    assert_no_tag :tag => 'a', :content => 'New <u>S</u>trategy'
    assert_no_tag :tag => 'a', :content => 'New <u>C</u>omment'
    assert_no_tag :tag => 'small', :content => '(drag to reorder)'
    #TODO: "Remove Factor" link should not be available
    #TODO: "Delete Factor" link should not be available
    #TODO: "Delete Strategy" link should not be available
    #TODO: "Quote Discussion" link should not be available
    #TODO: "Edit Discussion" link should not be available
    #TODO: "Delete Discussion" link should not be available
  end
  
  def test_show_invalid_id
    get :show, :project_id => 1, :id => 12345
    assert_response :not_found    
  end
  
  def test_show_hidden_forms
    get :show, :project_id => @ad.project.id, :id => @ad.id
    assert_response :success
    assert_select "a[href=?]", /.*factors\?arch_decision_id=#{@ad.id}&amp;mode=popup/, 
                  {:html => '<u>A</u>dd Factor'}
                  
    assert_select 'a', {:html => 'New <u>F</u>actor'}
    assert_select 'form[onsubmit=?]', /.*new_factor\/#{@ad.id}.*/ do
      assert_select 'select#factor_status_id'
      assert_select 'input#factor_summary'
    end

    assert_select 'a', {:html => 'New <u>S</u>trategy'}
    assert_select 'form[onsubmit=?]', /.*strategies\/new\?arch_decision_id=#{@ad.id}.*/ do
      assert_select 'input#strategy_short_name'
      assert_select 'input#strategy_summary'
    end

    assert_select 'a', {:html => 'New <u>C</u>omment'}
    assert_select 'form[action=?]', /.*discussions\/new.*/ do
      assert_select 'input[name=project_id]'
      assert_select 'input[name=arch_decision_id]'
      assert_select 'input#discussion_subject'
      assert_select 'textarea#discussion_content'
      assert_select 'input[name=?]', /attachments\[1\]\[file\]/
      assert_select 'input[name=?]', /attachments\[1\]\[description\]/
    end
  end
  
  def test_new
    get :new, :project_id => @ad.project.id
    assert_response :success
    assert_template 'new'
    assert_select "form[action=/projects/#{@ad.project.identifier}/arch_decisions/new]" do
      assert_select 'input#arch_decision_summary'
      assert_select 'textarea#arch_decision_problem_description'
      assert_select 'textarea#arch_decision_resolution'
      assert_select 'select#arch_decision_status_id'
      assert_select 'select#arch_decision_assigned_to_id'
    end
    # TODO: test watchers form
  end
  
  def test_new_post
    ad_count = ArchDecision.count(:all)
    post :new, :project_id => @ad.project.id, 
                :arch_decision => {
                  :summary => "test_new_post summary",
                  :problem_description => "test_new_post problem_description",
                  :resolution => "test_new_post resolution",
                  :status_id => arch_decision_statuses(:valid).id,
                  :assigned_to_id => users(:users_001).id,
                  :watcher_user_ids => [User.current.id, users(:users_001).id]
                }
    assert_equal ad_count+1, ArchDecision.count(:all)
    ad = assigns(:arch_decision)
    assert_equal "test_new_post summary", ad.summary
    assert_equal "test_new_post problem_description", ad.problem_description
    assert_equal "test_new_post resolution", ad.resolution
    assert_equal arch_decision_statuses(:valid), ad.status
    assert_equal users(:users_001), ad.assigned_to
    # Make sure watchers are assigned
    assert_equal 2, ad.watchers.size
    assert ad.watchers.collect{ |w| w.user }.include?(ad.created_by)
    assert ad.watchers.collect{ |w| w.user }.include?(ad.assigned_to)
  end
  
  def test_new_post_one_watcher
    ad_count = ArchDecision.count(:all)
    post :new, :project_id => @ad.project.id, 
                :arch_decision => {
                  :summary => "test_new_post summary",
                  :problem_description => "test_new_post problem_description",
                  :resolution => "test_new_post resolution",
                  :status_id => arch_decision_statuses(:valid).id,
                  :assigned_to_id => User.current.id,
                  :watcher_user_ids => [users(:users_001).id]
                }
    assert_equal ad_count+1, ArchDecision.count(:all)
    ad = assigns(:arch_decision)
    assert_equal ad.created_by, ad.assigned_to
    # There should only be one watcher
    assert_equal 1, ad.watchers.size
    assert !ad.watchers.collect{ |w| w.user }.include?(ad.created_by)
    assert !ad.watchers.collect{ |w| w.user }.include?(ad.assigned_to)
    assert ad.watchers.collect{ |w| w.user }.include?(users(:users_001))
  end
  
  def test_new_post_dont_add_watchers
    ad_count = ArchDecision.count(:all)
    post :new, :project_id => @ad.project.id, 
                :arch_decision => {
                  :summary => "test_new_post summary",
                  :problem_description => "test_new_post problem_description",
                  :resolution => "test_new_post resolution",
                  :status_id => arch_decision_statuses(:valid).id,
                  :assigned_to_id => User.current.id
                }
    assert_equal ad_count+1, ArchDecision.count(:all)
    ad = assigns(:arch_decision)
    assert_equal ad.created_by, ad.assigned_to
    # There should be no watchers despite assigned to value
    assert_equal 0, ad.watchers.size
  end
  
  def test_new_no_perms
    setup_user_no_permissions(@request)
    get :new, :project_id => @ad.project.id
    assert_response 403
  end
  
  def test_edit
    get :edit, :project_id => @ad.project.id, :id => @ad.id
    assert_response :success
    assert_template 'edit'
    assert_select "form[action=/projects/#{@ad.project.identifier}/arch_decisions/edit/#{@ad.id}]" do
      assert_select 'input#arch_decision_summary'
      assert_select 'textarea#arch_decision_problem_description'
      assert_select 'textarea#arch_decision_resolution'
      assert_select 'select#arch_decision_status_id'
      assert_select 'select#arch_decision_assigned_to_id'
    end
    # TODO: assert watchers form
  end
  
  def test_edit_post
    old_assignee = users(:users_001)
    assignee = users(:users_002)
    post :edit, :project_id => @ad.project.id,
                :id => @ad.id,
                :arch_decision => {
                  :summary => "test_edit_post summary",
                  :problem_description => "test_edit_post problem_description",
                  :resolution => "test_edit_post resolution",
                  :status_id => arch_decision_statuses(:valid_name_max_length).id,
                  :assigned_to_id => assignee.id,
                  :watcher_user_ids => [@ad.created_by.id, old_assignee.id]
                }
    ad = assigns(:arch_decision)
    assert_equal @ad.id, ad.id
    assert_equal "test_edit_post summary", ad.summary
    assert_equal "test_edit_post problem_description", ad.problem_description
    assert_equal "test_edit_post resolution", ad.resolution
    assert_equal arch_decision_statuses(:valid_name_max_length), ad.status
    assert_equal assignee, ad.assigned_to
    assert_equal 2, ad.watchers.size
    watching_users = ad.watchers.collect{ |w| w.user }
    assert watching_users.include?(ad.created_by)
    assert !watching_users.include?(ad.assigned_to)
    assert watching_users.include?(old_assignee)
  end
  
  def test_edit_post_assigned_to_unchanged
    assignee = users(:users_002)
    post :edit, :project_id => @ad.project.id,
                :id => @ad.id,
                :arch_decision => {
                  :summary => "test_edit_post summary",
                  :problem_description => "test_edit_post problem_description",
                  :resolution => "test_edit_post resolution",
                  :status_id => arch_decision_statuses(:valid_name_max_length).id,
                  :assigned_to_id => assignee.id,
                  :watcher_user_ids => [@ad.created_by.id, assignee.id]
                }
    ad = assigns(:arch_decision)
    assert_equal assignee, ad.assigned_to
    # Watch list should be unchanged
    assert_equal 2, ad.watchers.size
    watching_users = ad.watchers.collect{ |w| w.user }
    assert watching_users.include?(ad.created_by)
    assert watching_users.include?(ad.assigned_to)
  end

  def test_edit_post_dont_add_watchers
    assignee = users(:users_002)
    post :edit, :project_id => @ad.project.id,
                :id => @ad.id,
                :arch_decision => {
                  :summary => "test_edit_post summary",
                  :problem_description => "test_edit_post problem_description",
                  :resolution => "test_edit_post resolution",
                  :status_id => arch_decision_statuses(:valid_name_max_length).id,
                  :assigned_to_id => assignee.id,
                  :watcher_user_ids => [@ad.created_by.id]
                }
    ad = assigns(:arch_decision)
    assert_equal assignee, ad.assigned_to
    # Watch list should be unchanged
    assert_equal 1, ad.watchers.size
    watching_users = ad.watchers.collect{ |w| w.user }
    assert watching_users.include?(ad.created_by)
    assert !watching_users.include?(ad.assigned_to)
  end


  def test_edit_no_perms
    setup_user_no_permissions(@request)
    get :edit, :project_id => @ad.project.id, :id => @ad.id
    assert_response 403
  end
  
  def test_new_factor
    summary = 'test_new_factor summary'
    initial_num_factors = @ad.factors.size
    get :show, :project_id => @ad.project.id, :id => @ad.id
    assert_response :success
    assert_template 'show'
    assert_no_tag :tag => 'a', :content => /.*#{summary}.*/
    post :new_factor, :project_id => @ad.project.id, 
                      :id => @ad.id, 
                      :factor => {
                        :status_id => arch_decision_statuses(:valid).id, 
                        :summary => summary
                      }
    assert_equal initial_num_factors+1, @ad.factors.size
    (1..(@ad.factors.size)).each{ |n| 
      assert_equal n, @ad.arch_decision_factors[n-1].priority
    }
    assert_equal summary, @ad.factors[@ad.factors.size-1].summary
    get :show, :project_id => @ad.project.id, :id => @ad.id
    assert_tag :tag => 'a', :content => /.*#{summary}.*/
  end

  def test_new_factor_no_perms
    setup_user_no_permissions(@request)
    post :new_factor, :project_id => @ad.project.id, 
                      :id => @ad.id, 
                      :factor => {
                        :status_id => 1, 
                        :summary => "Test factor summary"
                      }
    assert_response 403
  end

  def test_add_factor
    factor = factors(:valid_ad_no_ad)
    initial_num_factors = @ad.factors.size
    get :show, :project_id => @ad.project.id, :id => @ad.id
    assert_response :success
    assert_template 'show'
    assert_no_tag :tag => 'a', :content => /.*#{factor.summary}.*/
    post :add_factor, :project_id => @ad.project.id, 
                      :id => @ad.id, 
                      :factor_id => factor.id
    assert_equal initial_num_factors+1, @ad.factors.size
    (1..(@ad.factors.size)).each{ |n| 
      assert_equal n, @ad.arch_decision_factors[n-1].priority
    }
    assert_equal factor.summary, @ad.factors[@ad.factors.size-1].summary
    get :show, :project_id => @ad.project.id, :id => @ad.id
    assert_tag :tag => 'a', :content => /.*#{factor.summary}.*/
  end

  def test_add_factor_no_perms
    setup_user_no_permissions(@request)
    factor = factors(:valid_ad_no_ad)
    post :add_factor, :project_id => @ad.project.id, 
                      :id => @ad.id, 
                      :factor_id => factor.id
    assert_response 403
  end

  def test_reorder_factors
    # TODO  
  end

  def test_reorder_factors_no_perms
    # TODO  
    # Test also the "drag to reorder" text
  end

  private
  
  def generate_test_ads(num = 25)
    (1..num).each do |n|
      ad = @ad.clone
      ad.summary = "Generated test AD#" + n.to_s
      ad.save
    end
  end
    
end
