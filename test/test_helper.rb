# encoding: utf-8

# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

class ActiveSupport::TestCase
  
  def assert_unique_fields_enforced(model, fields = [])
    assert_fields_have_error(model, fields, 
                               I18n.translate('activerecord.errors.messages.taken'))
  end
  
  def assert_required_fields_enforced(model, fields = [])
    assert_fields_have_error(model, fields, 
                                I18n.translate('activerecord.errors.messages.blank'))
  end
  
  def assert_fields_max_length_enforced(model, fields = [], lengths = [])
    fields.each_with_index do |field, index|
      assert_not_nil model.errors.on(field)
      message = I18n.translate('activerecord.errors.messages.too_long', :count => lengths[index])
      assert model.errors.on(field).include?(message), "Expected message '" + message + "' in " + model.errors.on(field) 
    end
  end
  
  def assert_fields_min_length_enforced(model, fields = [], lengths = [])
    fields.each_with_index do |field, index|
      assert_not_nil model.errors.on(field)
      message = I18n.translate('activerecord.errors.messages.too_short', :count => lengths[index])
      assert model.errors.on(field).include?(message), "Expected message '" + message + "' in " + model.errors.on(field) 
    end
  end
  
  def assert_fields_format_enforced(model, fields = [])
    assert_fields_have_error(model, fields, 
                                I18n.translate('activerecord.errors.messages.invalid'))
  end
  
  def assert_fields_have_error(model, fields, message)
    fields.each do |field|
      assert_not_nil model.errors.on(field)
      assert model.errors.on(field).include?(message), "Expected message '" + message + "' in " + model.errors.on(field).inspect 
    end
  end
  
  def enable_ad_module(project)
    project.enabled_modules << EnabledModule.new(:name => "arch_decisions")
  end
  
  def add_all_perms_to_role(role)
    role.add_permission!(:view_arch_decisions)
    role.add_permission!(:edit_arch_decisions)
    role.add_permission!(:delete_arch_decisions)
    role.add_permission!(:edit_factors)
    role.add_permission!(:delete_factors)
    role.add_permission!(:comment_arch_decisions)
  end
  
  def setup_user_with_permissions(request)
    request.session[:user_id] = 2
    User.current = users(:users_002)
    manager_role = roles(:roles_001)
    add_all_perms_to_role(manager_role)
  end
  
  def setup_user_view_permissions_only(request)
    request.session[:user_id] = 3
    User.current = users(:users_003)
    role = roles(:roles_002)
    role.add_permission!(:view_arch_decisions)
  end
  
  def setup_user_no_permissions(request)
    request.session[:user_id] = 4
    User.current = users(:users_004)
  end
  
end
