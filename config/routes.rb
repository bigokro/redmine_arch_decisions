ActionController::Routing::Routes.draw do |map|
  map.connect 'projects/:project_id/arch_decisions/:action', :controller => 'arch_decisions'
  map.connect 'projects/:project_id/arch_decisions/:action/:id', :controller => 'arch_decisions'
  map.connect 'projects/:project_id/arch_decisions/:action/:id/:factor_id', :controller => 'arch_decisions'
  map.connect 'projects/:project_id/factors/:action', :controller => 'factors'
  map.connect 'projects/:project_id/factors/:action/:id', :controller => 'factors'
  map.connect 'projects/:project_id/discussions/:action/:id', :controller => 'arch_decision_discussions'
end
