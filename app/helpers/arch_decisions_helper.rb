module ArchDecisionsHelper

  def autotab
    @current_tab ||= 0
    @current_tab += 1
  end

  # For some reason, different User classes are showing up, with different methods!
  def user_name(user)
    user.respond_to?(:name) ? user.name : user.login
  end

  # Returns a string of css classes that apply to the given AD
  def css_arch_decision_classes(ad)
    s = "issue"
    s << ' closed' unless ad.status.relevant?
    s << ' created-by-me' if User.current.logged? && ad.created_by_id == User.current.id
    s << ' assigned-to-me' if User.current.logged? && ad.assigned_to_id == User.current.id
    s
  end
  
end
