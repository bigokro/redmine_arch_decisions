class ShowIssueArchDecisionsHook < Redmine::Hook::ViewListener
  render_on :view_issues_show_description_bottom, :partial => "arch_decision_issues/related_arch_decisions"
end
