require 'redmine'
require 'mailer_extended'
require 'arch_decisions_issue_patch'
require 'show_issue_arch_decisions_hook'

Redmine::Plugin.register :redmine_arch_decisions do
  name 'Architecture Decisions plugin'
  author 'Timothy High'
  description 'A plugin for tracking architecture and design decisions for software projects'
  version '0.0.8'

  project_module :arch_decisions do
    permission :view_arch_decisions, {
                    :arch_decisions => [:index, :show],
                    :strategies => [:show],
                    :factors => [:index, :show]
                }
    permission :edit_arch_decisions, {
                    :arch_decisions => [:new, :edit, :add_factor, :remove_factor, :reorder_factors],
                    :arch_decision_issues => [:add_issue, :remove_issue],
                    :strategies => [:new, :edit, :destroy]
                }
    permission :delete_arch_decisions, {:arch_decisions => [:destroy]}
    permission :edit_factors, {
                    :arch_decisions => [:new_factor],
                    :factors => [:new, :edit]
                }
    permission :delete_factors, {
                    :arch_decisions => [:destroy_factor],
                    :factors => [:destroy]
                }
    permission :comment_arch_decisions, {:arch_decision_discussions => [:new, :edit, :destroy, :quote, :preview]}
  end

  menu :project_menu, :arch_decisions, { :controller => 'arch_decisions', :action => 'index' }, :caption => :label_arch_decision_plural, :param => :project_id
  menu :project_menu, :factors, { :controller => 'factors', :action => 'index' }, :caption => :label_factor_plural, :param => :project_id

end
