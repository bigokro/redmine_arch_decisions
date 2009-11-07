module ArchDecisionsHelper

  def autotab
    @current_tab ||= 0
    @current_tab += 1
  end

  # For some reason, different User classes are showing up, with different methods!
  def user_name(user)
    user.respond_to?(:name) ? user.name : user.login
  end

end
