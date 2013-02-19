class ArchDecisionDiscussion < ActiveRecord::Base
  SUBJECT_MAX_SIZE = 255

  belongs_to :arch_decision
  belongs_to :factor
  belongs_to :strategy
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'

  acts_as_attachable :view_permission => :view_arch_decisions, 
                      :delete_permission => :edit_arch_decisions 

  # TODO: Factors and Strategies don't belong to a project
  acts_as_searchable :columns => ['subject', 'content'],
                     :include => {:arch_decision => :project},
                     :project_key => 'project_id'

  validates_presence_of :subject, :content, :created_by
  validates_length_of :subject, :maximum => SUBJECT_MAX_SIZE

  def project
    if strategy
      strategy.project
    elsif arch_decision
      arch_decision.project
    elsif factor
      factor.project
    else
      nil
    end
  end

  def editable_by?(user)
    # TODO: implement permissions
    # user && user.logged? && self.created_by == user && user.allowed_to?(:edit_own_discussions, project)
    user && user.logged? && self.created_by == user
  end

  def destroyable_by?(user)
    # TODO: implement permissions
    # user && user.logged? && self.created_by == user && user.allowed_to?(:delete_own_discussions, project)
    user && user.logged? && self.created_by == user
  end

  def parent
    return factor unless factor.nil?
    return strategy unless strategy.nil?
    return arch_decision
  end

  def parent_type
    parent.class.name.titlecase
  end

  def type
    parent_type + " Discussion"
  end

  def recipients
    parent.nil? ? nil : parent.recipients
  end

  def watcher_recipients
    parent.nil? ? nil : parent.watcher_recipients
  end



  protected

  def validate
    if (arch_decision.nil? && factor.nil? && strategy.nil?)
      errors[:base] << :error_discussion_parents_nil
    end
  end

end
