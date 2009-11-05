class CreateArchDecisions < ActiveRecord::Migration
  def self.up
    create_table :arch_decisions do |t|
      t.column :summary, :string, :null => false
      t.column :problem_description, :text
      t.column :resolution, :text
      t.column "created_on", :timestamp
      t.column "updated_on", :timestamp
    end
  end

  def self.down
    drop_table :arch_decisions
  end
end
