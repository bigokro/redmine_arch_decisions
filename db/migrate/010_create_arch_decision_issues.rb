class CreateArchDecisionIssues < ActiveRecord::Migration
  def self.up
    create_table :arch_decision_issues do |t|
        t.references :arch_decision
        t.references :issue
        t.references :arch_decision_issue_type
        t.column :external_url, :string
        # Issue Type indicates the relationship between the AD and the Issue
        # - Task: The issue is some research or other task related to making the decision
        # - Proof of Concept: The issue represents proof-of-concept work related to testing a strategy
        # - Implementation: When the issue is completed, the system can be said to implement the decision
        # - Governed: Indicates that the work undertaken for the issue must follow the recommendations of the decision 
        t.column :issue_type, :string, :default => "Governed", :null => false
    end
    add_index :arch_decision_issues, :arch_decision_id, :name => :arch_decision_issues_arch_decision_id
    add_index :arch_decision_issues, :issue_id, :name => :arch_decision_issues_issue_id
    add_index :arch_decision_issues, [:arch_decision_id, :issue_id], :unique => true, :name => :arch_decision_issues_unique_pair
  end

  def self.down
    drop_table :arch_decision_issues
  end
end
