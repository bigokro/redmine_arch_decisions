class CreateArchDecisionDiscussions < ActiveRecord::Migration
  def self.up
    create_table :arch_decision_discussions do |t|
      t.references :arch_decision, :foreign_key => true, :null => true
      t.references :factor, :foreign_key => true, :null => true
      t.references :strategy, :foreign_key => true, :null => true
      t.column :subject, :string, :null => false
      t.column :content, :text
      t.references :created_by, :class_name =>"User", :foreign_key => true, :null => false
      t.column "created_on", :timestamp
      t.column "updated_on", :timestamp
    end
    add_index :arch_decision_discussions, [:arch_decision_id], :name => :add_ad_id
    add_index :arch_decision_discussions, [:factor_id], :name => :add_factor_id
    add_index :arch_decision_discussions, [:strategy_id], :name => :add_strategy_id
  end

  def self.down
    drop_table :arch_decision_discussions
  end
end
