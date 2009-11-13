require 'redmine'

Redmine::Plugin.register :redmine_arch_decisions do
  name 'Architecture Decisions plugin'
  author 'Timothy High'
  description 'A plugin for tracking architecture and design decisions for software projects'
  version '0.0.4.1'

  project_module :arch_decisions do
    permission :view_arch_decisions, {:arch_decisions => [:index, :show]}, :public => true
    permission :view_factors, {:factors => [:index, :show]}, :public => true
    permission :edit_arch_decisions, {
                    :arch_decisions => [:new, :edit, :destroy, :new_factor, :add_factor, :remove_factor, :destroy_factor],
                    :factors => [:new, :edit, :destroy]
                }, :public => true
  end

  menu :project_menu, :arch_decisions, { :controller => 'arch_decisions', :action => 'index' }, :caption => :label_arch_decision_plural, :param => :project_id
  menu :project_menu, :factors, { :controller => 'factors', :action => 'index' }, :caption => :label_factor_plural, :param => :project_id
end
