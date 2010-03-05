class FactorScope < ActiveRecord::Migration

  def self.up
    add_column :factors, :scope, :string, :default => "Global", :null => false
    add_column :factors, :project_id, :integer, :null => true

    # Update current factors:
    #   Assume that factors associated with exactly one AD have scope = "AD"
    #   Assume that factors associated with multiple ADs in the same project have scope = "Project"
    #   Assume that all others have a scope = "Global"
    Factor.all.each{ |f|
      if f.arch_decisions.size == 1
        f.scope = "AD"
        f.project_id = f.arch_decisions[0].project.id
        f.save
      elsif f.arch_decisions.size > 1
        project_id = f.arch_decisions[0].project.id
        other_ids = f.arch_decisions.select {|ad| ad.project.id != project_id}
        if other_ids.empty?
          f.scope = "Project"
          f.project_id = project_id
          f.save
        end
      end
    }
  end

  def self.down
    remove_column :factors, :scope
    remove_column :factors, :project_id
  end

end
