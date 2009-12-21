# A Factor is some piece of information that is relevant enough to one or more projects that it will influence the
# (technical) decisions made for that project. Factors can be listed inside an ArchDecision, but their scope may
# go well beyond the single decision, or even the project itself (for example, a piece of information regarding
# security issues with a specific framework might be relevant to all projects that use that framework).
#
# Many things can be recorded as factors:
#   - Functional Requirements
#   - Non-functional requirements (e.g. the Quality of Service attributes, or "-ilities")
#   - Project constraints (e.g. legal issues, project budget, project risks)
#   - Human factors (e.g. the "boss's" general preferences, political issues (be careful what you say in public!))
#   - Technical constraints (e.g. weaknesses and strengths of technologies)
#
# Factors are basically facts (or factoids, or supposed facts) that someone has offered up as a basis for a decision.
# The universe of possible Factors is infinite, so it would not make sense to record every possible one.
# Instead, the point is to elevate assumptions and rationale for potential decisions (i.e. ArchDecisions) into
# explicit (and, for the ArchDecision itself, prioritized) and validated reasons.
#
class Factor < ActiveRecord::Base
  SUMMARY_MAX_SIZE = 255

  has_many :arch_decision_factors, :dependent => :destroy
  has_many :arch_decisions, :through => :arch_decision_factors
  has_many :arch_decision_discussions, :dependent => :destroy, :order => "created_on"
  belongs_to :status, :class_name => "FactorStatus", :foreign_key => 'status_id'
  belongs_to :created_by, :class_name =>"User", :foreign_key => 'created_by_id'
  belongs_to :updated_by, :class_name =>"User", :foreign_key => 'updated_by_id'
  
  acts_as_searchable :columns => ['id', 'summary', 'details', 'evidence'], :factor_key => 'id', :permission => nil

  validates_presence_of :summary, :status
  validates_length_of :summary, :maximum => SUMMARY_MAX_SIZE

  def discussions
    arch_decision_discussions
  end
  
  def refuted?
    status.name == "Refuted"
  end

  def recipients
    recipient_list = []
    arch_decisions.each{ |ad| recipient_list << ad.recipients }
    recipient_list.compact.uniq
  end
    
  def watcher_recipients
    recipient_list = []
    arch_decisions.each{ |ad| recipient_list << ad.watcher_recipients }
    recipient_list.compact.uniq
  end
  
end
