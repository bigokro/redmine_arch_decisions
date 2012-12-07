# encoding: utf-8

module FactorsHelper

  # Returns a string of css classes that apply to the given Factor
  def css_factor_classes(f)
    s = "issue"
    s << ' created-by-me' if User.current.logged? && f.created_by_id == User.current.id
    s
  end
  
end
