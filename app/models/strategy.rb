# A Strategy is one possible solution for an Arch Decision
# Generally, the process of making a decision involved proposing one or more approaches for design
# and implementation. Each approach, or strategy, is then considered for its viability and weighed
# against the merits of other potential strategies. Eventually, all but one will be rejected
# (for reasons that should be clear based on the Factors listed), and the remaining option
# will become the officially chosen strategy for the decision.
class Strategy < ActiveRecord::Base
  SHORT_NAME_MAX_SIZE = 40

  belongs_to :arch_decision
  belongs_to :created_by, :class_name =>"User", :foreign_key => 'created_by_id'
  belongs_to :updated_by, :class_name =>"User", :foreign_key => 'updated_by_id'
  
  validates_presence_of :short_name, :arch_decision_id, :created_by, :updated_by, :created_on, :updated_on
  validates_length_of :short_name, :maximum => SHORT_NAME_MAX_SIZE
  
  def rejected?
    return self.is_rejected
  end
end
