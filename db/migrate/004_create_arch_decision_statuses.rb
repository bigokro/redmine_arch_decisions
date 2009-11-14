class CreateArchDecisionStatuses < ActiveRecord::Migration
  def self.up
    create_table :arch_decision_statuses do |t|
      t.column :name, :string, :null => false
      t.column :is_resolved, :boolean
      t.column :is_complete, :boolean
      t.column :is_irrelevant, :boolean
      t.column :position, :integer, :null => false
    end
    ArchDecisionStatus.create :name => "Not Started", :is_resolved => false, :is_complete => false, :is_irrelevant => false, :position => 1
    ArchDecisionStatus.create :name => "Under Discussion", :is_resolved => false, :is_complete => false, :is_irrelevant => false, :position => 2
    ArchDecisionStatus.create :name => "Decision Made", :is_resolved => true, :is_complete => false, :is_irrelevant => false, :position => 3
    ArchDecisionStatus.create :name => "Work Scheduled", :is_resolved => true, :is_complete => false, :is_irrelevant => false, :position => 4
    ArchDecisionStatus.create :name => "Implemented", :is_resolved => true, :is_complete => true, :is_irrelevant => false, :position => 5
    ArchDecisionStatus.create :name => "Canceled", :is_resolved => false, :is_complete => false, :is_irrelevant => true, :position => 6
    ArchDecisionStatus.create :name => "Deprecated", :is_resolved => false, :is_complete => false, :is_irrelevant => true, :position => 7
    
    add_column :arch_decisions, :status_id, :integer, :null => false, :default => 1
  end

  def self.down
    drop_table :arch_decision_statuses
  end
end
