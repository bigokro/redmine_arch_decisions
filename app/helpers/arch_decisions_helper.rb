# encoding: utf-8

module ArchDecisionsHelper

  def autotab
    @current_tab ||= 0
    @current_tab += 1
  end

  # For some reason, different User classes are showing up, with different methods! (dev mode only)
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
  
  def text_for_discussion_count(item)
    label = case item.arch_decision_discussions.size
              when 0 then :text_discussion_count_none
              when 1 then :text_discussion_count_singular
              else :text_discussion_count_plural
    end
    return "<span class='discussion-count'>(" + t(label, :count => item.arch_decision_discussions.size.to_s) + ")</span>"
  end


end
