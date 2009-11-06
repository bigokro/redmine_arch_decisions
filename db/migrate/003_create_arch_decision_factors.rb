class CreateArchDecisionFactors < ActiveRecord::Migration
  def self.up
    create_table :arch_decision_factors do |t|
        t.references :arch_decision
        t.references :factor
        t.column :priority, :integer, :default => 1, :null => false
    end
    add_index :arch_decision_factors, :arch_decision_id, :name => :arch_decision_factors_arch_decision_id
    add_index :arch_decision_factors, :factor_id, :name => :arch_decision_factors_factor_id
    add_index :arch_decision_factors, [:arch_decision_id, :factor_id], :unique => true, :name => :arch_decision_factors_unique_pair
  end

  def self.down
    drop_table :arch_decision_factors
  end
end
