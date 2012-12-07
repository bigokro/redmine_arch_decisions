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
# As of version 0.0.7, Factors have a "scope" attribute that can be equal to one of the constant values below.
# Iff the scope is "Project", they will also have an associated project enitity.
# If the scope is "AD", they must have at most one AD associated with them (but no project)
#
class Factor < ActiveRecord::Base
  SUMMARY_MAX_SIZE = 255
  SCOPE_GLOBAL = "Global"
  SCOPE_PROJECT = "Project"
  SCOPE_ARCH_DECISION = "AD"

  has_many :arch_decision_factors, :dependent => :destroy
  has_many :arch_decisions, :through => :arch_decision_factors
  has_many :arch_decision_discussions, :dependent => :destroy, :order => "created_on"
  belongs_to :status, :class_name => "FactorStatus", :foreign_key => 'status_id'
  belongs_to :created_by, :class_name =>"User", :foreign_key => 'created_by_id'
  belongs_to :updated_by, :class_name =>"User", :foreign_key => 'updated_by_id'
  belongs_to :project

  acts_as_searchable :columns => ['id', 'summary', 'details', 'evidence'], :factor_key => 'id', :permission => nil

  validates_presence_of :summary, :status, :scope
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

  def scope_name
    Factor.scope_name(scope)
  end

  def self.scope_name(scope)
    case scope
      when SCOPE_GLOBAL then l(:label_factor_scope_global)
      when SCOPE_PROJECT then l(:label_factor_scope_project)
      when SCOPE_ARCH_DECISION then l(:label_factor_scope_arch_decision)
    end
  end

  def self.scopes
    [SCOPE_GLOBAL, SCOPE_PROJECT, SCOPE_ARCH_DECISION]
  end

  protected

  def validate
    errors[:base] << :error_factor_scope_invalid unless Factor.scopes.include?(scope)
    
    if project.nil?
      errors[:base] << :error_factor_project_nil if scope != SCOPE_GLOBAL
    elsif scope != SCOPE_GLOBAL
      errors[:base] << :error_factor_project_mismatch unless arch_decisions.select{|ad| ad.project != project}.empty?
    else
      errors[:base] << :error_factor_project_not_nil 
    end
    
    if scope == SCOPE_ARCH_DECISION && arch_decisions.size > 1
      errors[:base] << :error_factor_multiple_ads 
    end
  end
end

