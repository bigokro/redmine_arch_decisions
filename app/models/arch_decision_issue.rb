# This is an association class, or "cross-reference" class which supports a qualified many-to-many
# relationship between ArchDecisions and Redmine Issues.
# The relationship is qualified by a "issue_type" field, which indicates how the issue is related to the AD:
# - Task: The issue is some research or other task related to making the decision
# - Proof of Concept: The issue represents proof-of-concept work related to testing a strategy
# - Implementation: When the issue is completed, the system can be said to implement the decision
# - Governed: Indicates that the work undertaken for the issue must follow the recommendations of the decision 
# There is also an optional "External URL" field. This can be used in cases where Redmine is not being
# used to track the issue in question. In this case, the issue may be nil, but then a URL is required.
class ArchDecisionIssue < ActiveRecord::Base
  URL_MAX_SIZE = 255
  ISSUE_TYPE_TASK = "Task"
  ISSUE_TYPE_POC = "Proof of Concept"
  ISSUE_TYPE_IMPL = "Implementation"
  ISSUE_TYPE_GOV = "Governed"

  belongs_to :arch_decision
  belongs_to :issue
  
  def issue_type_name
    ArchDecisionIssue.issue_type_name(issue_type)
  end
  
  def self.issue_type_name(issue_type)
    case issue_type
      when ISSUE_TYPE_TASK then l(:label_ad_issue_type_task)
      when ISSUE_TYPE_POC then l(:label_ad_issue_type_poc)
      when ISSUE_TYPE_IMPL then l(:label_ad_issue_type_impl)
      when ISSUE_TYPE_GOV then l(:label_ad_issue_type_gov)
    end
  end
  
  def issue_type_phrase
    ArchDecisionIssue.issue_type_phrase(issue_type)
  end
  
  def self.issue_type_phrase(issue_type)
    case issue_type
      when ISSUE_TYPE_TASK then l(:label_ad_issue_type_task_phrase)
      when ISSUE_TYPE_POC then l(:label_ad_issue_type_poc_phrase)
      when ISSUE_TYPE_IMPL then l(:label_ad_issue_type_impl_phrase)
      when ISSUE_TYPE_GOV then l(:label_ad_issue_type_gov_phrase)
    end
  end
  
  def self.issue_types
    [ISSUE_TYPE_TASK, ISSUE_TYPE_POC, ISSUE_TYPE_IMPL, ISSUE_TYPE_GOV]
  end

  # TODO: method for sort order

  protected

  def validate
    errors[:base] << :error_ad_issue_type_invalid unless ArchDecisionIssue.issue_types.include?(issue_type)
    errors[:base] << :error_ad_issue_url_and_issue_nil unless issue || external_url
  end
end
