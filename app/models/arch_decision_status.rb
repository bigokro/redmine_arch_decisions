class ArchDecisionStatus < ActiveRecord::Base
  NAME_MAX_SIZE = 30

  acts_as_list

  validates_presence_of :name, :position
  validates_uniqueness_of :name, :position
  validates_length_of :name, :maximum => NAME_MAX_SIZE
  validates_format_of :name, :with => /^[\w\s\'\-]*$/i
  
  def resolved?
    return self.is_resolved
  end
  
  def complete?
    return self.is_complete
  end
  
  def relevant?
    return !self.is_irrelevant
  end
  
  # Converts the name into a locale key
  def name_key
    ("arch_decision_status_" + name.downcase.sub(' ', '_')).to_s
  end
 
  # Specify a default order
#  def self.find(*args)
#    options = args.last.is_a?(Hash) ? args.pop : {}
#    if not options.include? :order
#      options[:order] = 'position asc'
#    end
#    args.push(options)
#    super
#  end
end
