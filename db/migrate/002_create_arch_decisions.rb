class CreateArchDecisions < ActiveRecord::Migration
  def self.up
    create_table :arch_decisions do |t|
      t.column :summary, :string, :null => false
      t.column :problem_description, :text
      t.column :resolution, :text
      t.references :project, :null => false
      t.references :created_by, :class_name =>"User", :foreign_key => true, :null => false
      t.references :updated_by, :class_name =>"User", :foreign_key => true, :null => false
      t.references :assigned_to, :class_name =>"User", :foreign_key => true
      t.column "created_on", :timestamp
      t.column "updated_on", :timestamp
    end
  end

  def self.down
    drop_table :arch_decisions
  end
end
