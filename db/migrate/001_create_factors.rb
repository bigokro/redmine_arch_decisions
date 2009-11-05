class CreateFactors < ActiveRecord::Migration
  def self.up
    create_table :factors do |t|
      t.column :summary, :string, :null => false
      t.column :details, :text
      t.column :evidence, :text
      t.column "created_on", :timestamp
      t.column "updated_on", :timestamp
    end
  end

  def self.down
    drop_table :factors
  end
end
