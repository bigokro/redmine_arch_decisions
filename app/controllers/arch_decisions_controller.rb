class ArchDecisionsController < ApplicationController

  before_filter :load_page_model, :except => [:index, :new]
  before_filter :set_updated_by, :except => [:index, :new, :destroy, :show]
#  before_filter :authorize

  helper :sort
  include SortHelper  
  helper :arch_decisions
  helper :attachments

  def index
    sort_init 'id', 'desc'
    sort_update %w(id summary status_id assigned_to_id updated_on)

    c = ARCondition.new()
    
    @project = Project.find(params[:project_id])
    c << ["project_id = ?", @project.id]

    unless params[:summary].blank?
      summary = "%#{params[:summary].strip.downcase}%"
      c << ["LOWER(summary) LIKE ? OR id = ?", summary, params[:summary].to_i]
    end
    
    @arch_decision_count = ArchDecision.count(:conditions => c.conditions)
    @arch_decision_pages = Paginator.new self, @arch_decision_count,
                per_page_option,
                params['page']                
    @arch_decisions = ArchDecision.find :all, :order => sort_clause,
                        :conditions => c.conditions,
            :limit  =>  @arch_decision_pages.items_per_page,
            :offset =>  @arch_decision_pages.current.offset

    render :action => "index", :layout => false if request.xhr?
  end


  def show
    @factor_statuses = FactorStatus.find(:all)
    @discussions = @arch_decision.discussions
    @discussion = ArchDecisionDiscussion.new()
    @discussion.subject = "Re: " + @arch_decision.summary
  end


  def new
    @project = Project.find(params[:project_id])
    @arch_decision = ArchDecision.new(params[:arch_decision])
    @arch_decision.project = @project
    @arch_decision_statuses = ArchDecisionStatus.find(:all)
    if request.post?
      @arch_decision.created_by = User.current
      @arch_decision.updated_by = User.current
      if @arch_decision.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to( :action => 'show', :project_id => @project, :id => @arch_decision )
      end
    end
  end


  def edit
    if request.post?
      if @arch_decision.update_attributes(params[:arch_decision])
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'show', :project_id => @project, :id => @arch_decision
      else
        @arch_decision_statuses = ArchDecisionStatus.find(:all)
        show
        render :action => 'show'
      end
    else
      @arch_decision_statuses = ArchDecisionStatus.find(:all)
      show
    end
  end

  def destroy
    if @arch_decision.destroy
      flash[:notice] = l(:notice_successful_delete)
    end
    redirect_to :action => 'index', :project_id => @project
  end

  def new_factor
    # TODO: DRY this code with the FactorsController.new method
    @factor = Factor.new(params[:factor])
    @factor.created_by = User.current
    @factor.updated_by = User.current
    priority = @arch_decision.factors.count + 1
    if @factor.save
      adf = ArchDecisionFactor.new({ :arch_decision_id => params[:id], 
                                      :factor_id => @factor.id, 
                                      :priority => priority })
      adf.save
    end
    refresh_factors_table
  end

  def destroy_factor
    @arch_decision.destroy_factor(params[:factor_id].to_i)
    refresh_factors_table
  end

  def add_factor
    priority = @arch_decision.factors.count + 1
    adf = ArchDecisionFactor.new(:arch_decision_id => @arch_decision.id, 
                                  :factor_id => params[:factor_id],
                                  :priority => priority)
    adf.save
    render :action => 'add_factor', :layout => false
  end

  def remove_factor
    @arch_decision.remove_factor(params[:factor_id].to_i)
    refresh_factors_table
  end

  def reorder_factors
    above_id = params[:above] ? params[:above].to_i : nil
    below_id = params[:below] ? params[:below].to_i : nil
    @arch_decision.prioritize_factor(above_id, below_id)
    refresh_factors_table
  end


  private 

  def load_page_model
    @arch_decision = ArchDecision.find(params[:id])
    @project = Project.find(params[:project_id])
  end
  
  def set_updated_by
    @arch_decision.updated_by = User.current
    @arch_decision.updated_on = Time.now
    @arch_decision.save
  end
  
  def refresh_factors_table
    @factor = nil
    @factor_statuses = FactorStatus.find(:all)
    respond_to do |format|
      format.js do
        render :update do |page|
            page.replace_html "related_factors", :partial => "related_factors"
        end
      end
    end
  end
end
