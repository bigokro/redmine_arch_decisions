class FactorsController < ApplicationController

  before_filter :load_project
#  before_filter :authorize

  helper :sort
  include SortHelper  
  helper :arch_decisions
  helper :attachments

  def index
    sort_init 'id', 'desc'
    sort_update %w(id summary status_id updated_on)

    c = ARCondition.new()

    if params[:mode] == 'popup'
      @popup = true
      @arch_decision = ArchDecision.find(params[:arch_decision_id])
      factor_ids = @arch_decision.factors.collect{|factor| factor.id}
      c << ["NOT id IN (?)", factor_ids] if factor_ids.size > 0
    end

    unless params[:summary].blank?
      summary = "%#{params[:summary].strip.downcase}%"
      c << ["LOWER(summary) LIKE ? OR id = ?", summary, params[:summary].to_i]
    end

    @factor_count = Factor.count(:conditions => c.conditions)
    @factor_pages = Paginator.new self, @factor_count,
                per_page_option,
                params['page']
    @factors = Factor.find :all, :order => sort_clause,
                        :conditions => c.conditions,
            :limit  =>  @factor_pages.items_per_page,
            :offset =>  @factor_pages.current.offset

    if params[:mode] == 'popup'
      render :layout => 'popup'  
    else
      render :action => "index", :layout => false if request.xhr?
    end
  end


  def show
    @factor = Factor.find(params[:id])
    @discussions = @factor.discussions
    @discussion = ArchDecisionDiscussion.new()
    @discussion.subject = "Re: " + @factor.summary
  end


  def new
    @factor = Factor.new(params[:factor])
    @factor_statuses = FactorStatus.find(:all)
    if request.post?
      @factor.created_by = User.current
      @factor.updated_by = User.current
      if @factor.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to( :action => 'show', :project_id => @project, :id => @factor )
        return
      end   
    end
  end


  def edit
    if request.post?
      @factor = Factor.find(params[:id])
      @factor.updated_by = User.current
      if @factor.update_attributes(params[:factor])
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'show', :project_id => @project, :id => @factor
      else
        @factor_statuses = FactorStatus.find(:all)
        show
        render :action => 'show'
      end
    else
      @factor_statuses = FactorStatus.find(:all)
      show
    end
  end


  def destroy
    @factor = Factor.find(params[:id])
    if @factor.destroy
      flash[:notice] = l(:notice_successful_delete)
    end
    redirect_to :action => 'index', :project_id => @project
  end

  private

  def load_project
    @project = Project.find(params[:project_id])
  end

end
