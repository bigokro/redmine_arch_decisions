# An "Arch Decision" is a decision about the architecture (or a design decision) which will either have a big impact
# on the project architecture/design, which requires serious discussion between project members, which requires
# some permanent record of why the decision was made, or all of the above.
#
# Arch Decisions should generally be made based on a set of validated and prioritized Factors.
# 
class ArchDecision < ActiveRecord::Base
  SUMMARY_MAX_SIZE = 255
  
  has_many :arch_decision_factors, :dependent => :destroy
  has_many :factors, :through => :arch_decision_factors, :order => "priority"
  belongs_to :project
  belongs_to :created_by, :class_name =>"User", :foreign_key => 'created_by_id'
  belongs_to :assigned_to, :class_name =>"User", :foreign_key => 'assigned_to_id'
  
  
  acts_as_searchable :columns => ['summary', 'problem_description', 'resolution'], :arch_decision_key => 'id', :permission => nil
  
  validates_presence_of :summary, :project, :created_by
  validates_length_of :summary, :maximum => SUMMARY_MAX_SIZE
  
  
  def remove_factor(factor_id)
    adfs = self.arch_decision_factors.select{|adf| adf.factor_id == factor_id}
    if adfs[0]
      adfs[0].destroy
      recalc_priorities
    else
      raise "No factors were found matching id #{factor_id}"
    end
  end

  def destroy_factor(factor_id)
    factors = self.factors.select{|f| f.id == factor_id}
    if factors[0]
      factors[0].destroy
      recalc_priorities
    else
      raise "No factors were found matching id #{factor_id}"
    end
  end


  
  private
  
  def recalc_priorities
    priority = 1
    reload
    arch_decision_factors.sort{|a,b| a.priority <=> b.priority}.each{ |adf|
      adf.priority = priority
      adf.save!
      priority += 1
    }
    save!
  end

end
