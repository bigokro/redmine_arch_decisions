# Due to a bug in the ArchDecisionDiscussionsController
# (Bug #586 - http://opensource.integritas.com.br/issues/show/586),
# Comments associated with Strategies were also being associated with the related ArchDecision
# This script removes the extra association
class CleanUpStrategyDiscussions < ActiveRecord::Migration
  def self.up
    discussions = find_strategy_discussions
    discussions.each{ |discussion| 
      discussion.arch_decision = nil
      discussion.save
    }
  end

  def self.down
    discussions = find_strategy_discussions
    discussions.each{ |discussion| 
      discussion.arch_decision = discussion.strategy.arch_decision
      discussion.save
    }
  end
  
  private
  
  def self.find_strategy_discussions
    discussions = ArchDecisionDiscussion.find(:all, :conditions => "NOT strategy_id IS NULL")
  end
end
