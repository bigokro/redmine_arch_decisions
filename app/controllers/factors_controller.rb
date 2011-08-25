class FactorsController < ApplicationController

  before_filter :load_project
  before_filter :authorize

  menu_item :arch_decisions

  helper :sort
  include SortHelper  
  helper :arch_decisions
  helper :attachments

  def index
    sort_init 'id', 'desc'
    sort_update %w(id summary status_id scope updated_on)

    c = ARCondition.new()

    if params[:mode] == 'popup'
      @popup = true

      # Don't list Factors already associated with the current Arch Decision
      @arch_decision = ArchDecision.find(params[:arch_decision_id])
      factor_ids = @arch_decision.factors.collect{|factor| factor.id}
      c << ["NOT id IN (?)", factor_ids] if factor_ids.size > 0
      
      # Index should only list globally-scoped Factors, project-scoped Factors associated with this project
      # and AD-scoped Factors associated with the project that don't yet have an AD
      # PERF: better to do this as a single select than to load all these Factors into memory
      ad_factors = Factor.find(:all, :conditions => {:project_id => @project.id, :scope => Factor::SCOPE_ARCH_DECISION})
      unassigned_ad_factor_ids = ad_factors.select{|f| f.arch_decisions.empty?}.collect{|f| f.id}
      unassigned_ad_factor_ids = [0] if unassigned_ad_factor_ids.empty?
      c << ["scope = '#{Factor::SCOPE_GLOBAL}' OR (project_id = ? AND scope = '#{Factor::SCOPE_PROJECT}') OR id IN (?)", 
              @project.id,
              unassigned_ad_factor_ids]
    else
      # Index should only list globally-scoped Factors and those associated with this project
      c << ["scope = '#{Factor::SCOPE_GLOBAL}' OR project_id = ?", @project.id] #"
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
    @factor_scopes = Factor.scopes
    @factor_statuses = FactorStatus.find(:all)
    if request.post?
      adjust_for_scope @factor
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
      adjust_for_scope @factor
      @factor.updated_by = User.current
      if @factor.update_attributes(params[:factor])
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'show', :project_id => @project, :id => @factor
      else
        @factor_statuses = FactorStatus.find(:all)
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
    @project = Project.find_by_id(params[:project_id].to_i) || Project.find_by_identifier(params[:project_id]) 
  end

  def adjust_for_scope(factor)
    scope = params[:factor][:scope]
    if scope != Factor::SCOPE_GLOBAL
      factor.project = @project
    else
      factor.project = nil 
    end
  end

end
