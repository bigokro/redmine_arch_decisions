ActionController::Routing::Routes.draw do |map|
  map.connect 'arch_decisions/:action/:id/:factor_id', :controller => 'arch_decisions'
end
