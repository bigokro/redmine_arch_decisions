class FactorStatus < ActiveRecord::Base
  NAME_MAX_SIZE = 30
  
  acts_as_list

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => NAME_MAX_SIZE
  validates_format_of :name, :with => /^[\w\s\'\-]*$/i
  
  # Converts the name into a locale key
  def name_key
    ("factor_status_" + name.downcase.sub(' ', '_')).to_s
  end
 
end
