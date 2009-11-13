# This is an association class, or "cross-reference" class which supports a qualified many-to-many
# relationship between ArchDecisions and their supporting Factors.
# The relationship is qualified by a "priority" field, which must be unique per ArchDecision.
# This field indicates which factors are more important, or have the greatest bearing 
# on the architecture decision at hand
class ArchDecisionFactor < ActiveRecord::Base
  belongs_to :arch_decision
  belongs_to :factor
end
