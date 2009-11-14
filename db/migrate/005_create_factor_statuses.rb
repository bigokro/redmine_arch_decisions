class CreateFactorStatuses < ActiveRecord::Migration
  def self.up
    create_table :factor_statuses do |t|
      t.column :name, :string
      t.column :position, :integer
    end
    FactorStatus.create :name => "Proposed", :position => 1
    FactorStatus.create :name => "Under Discussion", :position => 2
    FactorStatus.create :name => "Validated", :position => 3
    FactorStatus.create :name => "Refuted", :position => 4
    
    add_column :factors, :status_id, :integer, :null => false, :default => 1
  end

  def self.down
    drop_table :factor_statuses
  end
end
