class StrategiesController < ApplicationController

  before_filter :load_full_model, :except => [:new]
  before_filter :load_parent_model, :only => [:new]
  before_filter :authorize

  helper :arch_decisions
  helper :attachments

  def new
    @strategy = Strategy.new(params[:strategy])
    @strategy.arch_decision = @arch_decision
    if request.post?
      @strategy.created_by = User.current
      @strategy.updated_by = User.current
      @strategy.save
      # Clear out Strategy so it doesn't pre-fill the "new" form
      @strategy = nil
    end
    refresh_strategies_table
  end


  def edit
    if request.post? || request.put?
      @strategy.updated_by = User.current
      @strategy.updated_on = Time.now
      if @strategy.update_attributes(params[:strategy])
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'show', :id => @strategy
      else
        show
        render :action => 'show'
      end
    else
      show
    end
  end


  def show
    @discussions = @strategy.discussions
    @discussion = ArchDecisionDiscussion.new()
    @discussion.subject = "Re: " + @strategy.short_name
  end


  def destroy
    @strategy.destroy
    # Clear out Strategy so it doesn't pre-fill the "new" form
    @strategy = nil
    refresh_strategies_table
  end

  private

  def load_full_model
    @strategy = Strategy.find(params[:id])
    @arch_decision = @strategy.arch_decision
    @project = @arch_decision.project
  end

  def load_parent_model
    @arch_decision = ArchDecision.find(params[:arch_decision_id])
    @project = @arch_decision.project
  end

  def refresh_strategies_table
    respond_to do |format|
      format.js
    end
  end

end
