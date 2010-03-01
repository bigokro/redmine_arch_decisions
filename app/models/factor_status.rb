class FactorStatus < ActiveRecord::Base
  NAME_MAX_SIZE = 30
  
  acts_as_list

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => NAME_MAX_SIZE
  validates_format_of :name, :with => /^[\w\s\'\-]*$/i
end
