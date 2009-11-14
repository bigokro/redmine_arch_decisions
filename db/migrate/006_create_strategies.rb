class CreateStrategies < ActiveRecord::Migration
  def self.up
    create_table :strategies do |t|
      t.references :arch_decision, :foreign_key => true, :null => false
      t.column :short_name, :string, :limit => 40, :null => false 
      t.column :summary, :string
      t.column :details, :text
      t.column :reason_rejected, :text
      t.column :is_rejected, :boolean, :default => false
      t.column :position, :integer
      t.references :created_by, :class_name =>"User", :foreign_key => true, :null => false
      t.references :updated_by, :class_name =>"User", :foreign_key => true, :null => false
      t.column "created_on", :timestamp
      t.column "updated_on", :timestamp
    end
  end

  def self.down
    drop_table :strategies
  end
end
