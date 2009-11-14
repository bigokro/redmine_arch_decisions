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
  has_many :strategies, :dependent => :destroy, :order => "is_rejected, position"
  belongs_to :project
  belongs_to :status, :class_name => "ArchDecisionStatus", :foreign_key => 'status_id'
  belongs_to :created_by, :class_name =>"User", :foreign_key => 'created_by_id'
  belongs_to :updated_by, :class_name =>"User", :foreign_key => 'updated_by_id'
  belongs_to :assigned_to, :class_name =>"User", :foreign_key => 'assigned_to_id'
  
  acts_as_searchable :columns => ['summary', 'problem_description', 'resolution'], :arch_decision_key => 'id', :permission => nil
  
  validates_presence_of :summary, :project, :status, :created_by, :updated_by
  validates_length_of :summary, :maximum => SUMMARY_MAX_SIZE
  
  
  def remove_factor(factor_id)
    adfs = self.arch_decision_factors.select{|adf| adf.factor_id == factor_id}
    if adfs[0]
      adfs[0].destroy
      reload
      recalc_priorities
    else
      raise "No factors were found matching id #{factor_id}"
    end
  end

  def destroy_factor(factor_id)
    factors = self.factors.select{|f| f.id == factor_id}
    if factors[0]
      factors[0].destroy
      reload
      recalc_priorities
    else
      raise "No factors were found matching id #{factor_id}"
    end
  end

  # Changes priorities so that the Factor with id = above_id
  # is given a higher priority than the one with id = below_id
  # (all others in the list are adjusted accordingly)
  # If below_id is nil, then the above_id Factor is moved to the top;
  # If above_id is nil, then the below_id Factor is moved to the bottom
  def prioritize_factor(above_id, below_id = nil)
    priority = 1
    if below_id
      below = self.arch_decision_factors.select{|adf| adf.factor_id == below_id}[0]
      priority = below.priority
    end
    if above_id == nil
      below.priority = self.arch_decision_factors.count + 1
    else
      arch_decision_factors.sort{|a,b| a.priority <=> b.priority}.each{ |adf|
        if adf.factor_id == above_id
          adf.priority = priority
        elsif adf.priority >= priority
          adf.priority += 1
        end
      }
    end
    recalc_priorities
  end

  # Users the AD can be assigned to
  def assignable_users
    project.assignable_users
  end

  private
  
  def recalc_priorities
    priority = 1
    arch_decision_factors.sort{|a,b| a.priority <=> b.priority}.each{ |adf|
      adf.priority = priority
      adf.save!
      priority += 1
    }
    save!
  end

end
