require_dependency 'issue'
 
# Patches Redmine's Issues dynamically. Adds a relationship
# Issue +has_many+ to ArchDecisionIssue
# Copied from dvandersluis' redmine_resources plugin: 
# http://github.com/dvandersluis/redmine_resources/blob/master/lib/resources_issue_patch.rb
module IssuePatch
  def self.included(base) # :nodoc:
    # Same as typing in the class
    base.class_eval do
      has_many :arch_decision_issues, :class_name => 'ArchDecisionIssue', :foreign_key => 'issue_id', :dependent => :delete_all, :order => "issue_type DESC"
    end
  end
end
 
Issue.send(:include, IssuePatch)