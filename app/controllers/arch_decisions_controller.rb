class ArchDecisionsController < ApplicationController
  unloadable

  helper :sort
  include SortHelper  

  def index
    sort_init 'id', 'asc'
    sort_update %w(id summary created_on)

    c = ARCondition.new()

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
    @arch_decision = ArchDecision.find(params[:id])
  end


  def new
    @arch_decision = ArchDecision.new(params[:arch_decision])
    if request.get?
      # need to do anything?
    else
      if @arch_decision.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to( :action => 'show', :id => @arch_decision )
        return
      end   
    end
  end


  def edit
    if request.post?
      @arch_decision = ArchDecision.find(params[:id])
      if @arch_decision.update_attributes(params[:arch_decision])
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'show', :id => @arch_decision
      else
        show
        render :action => 'show'
      end
    else
      show
    end
  end

  def destroy
    @arch_decision = ArchDecision.find(params[:id])
    if @arch_decision.destroy
      flash[:notice] = l(:notice_successful_delete)
    end
    redirect_to :action => 'index'
  end

  def new_factor
    @factor = Factor.new(params[:factor])
    @arch_decision = ArchDecision.find(params[:id])
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
    @arch_decision = ArchDecision.find(params[:id])
    @arch_decision.destroy_factor(params[:factor_id].to_i)
    refresh_factors_table
  end

  def add_factor
    @arch_decision = ArchDecision.find(params[:id])
    priority = @arch_decision.factors.count + 1
    adf = ArchDecisionFactor.new(:arch_decision_id => @arch_decision.id, 
                                  :factor_id => params[:factor_id],
                                  :priority => priority)
    adf.save
    render :action => 'add_factor', :layout => false
  end

  def remove_factor
    @arch_decision = ArchDecision.find(params[:id])
    @arch_decision.remove_factor(params[:factor_id].to_i)
    refresh_factors_table
  end

  private 
  
  def refresh_factors_table
    respond_to do |format|
      format.js do
        render :update do |page|
            page.replace_html "related_factors", :partial => "related_factors"
        end
      end
    end
  end
end
