class ArchDecisionStatus < ActiveRecord::Base
  acts_as_list

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 30
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
