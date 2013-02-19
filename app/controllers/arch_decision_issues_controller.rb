class ArchDecisionIssuesController < ApplicationController

  before_filter :load_model
  before_filter :authorize

  def add_issue
    adi = ArchDecisionIssue.new(params[:arch_decision_issue])
    if adi.save
      @arch_decision_issue = nil
    else
      @arch_decision_issue = adi
    end
    if (params[:return_to] == "issue")
      refresh_arch_decisions_table
    else
      refresh_issues_table
    end
  end

  def remove_issue
    if @arch_decision_issue
      @arch_decision_issue.destroy
    else
      @arch_decision.remove_issue(params[:issue_id].to_i)
    end
    if (params[:return_to] == "issue")
      refresh_arch_decisions_table
    else
      @arch_decision.reload
      refresh_issues_table
    end
  end

  private 
  
  def load_model
    @project = Project.find(params[:project_id])
    valmap = params[:arch_decision_issue] ? params[:arch_decision_issue] : params
    ad_id = valmap[:arch_decision_id]
    i_id = valmap[:issue_id]
    adi_id = valmap[:arch_decision_issue_id]
    @arch_decision = ArchDecision.find(ad_id)
    @issue = Issue.find(i_id) unless i_id.nil? || i_id.empty?
    @arch_decision_issue = ArchDecisionIssue.find(adi_id) unless adi_id.nil? || adi_id.empty?
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def load_arch_decision
    @arch_decision = ArchDecision.find(params[:arch_decision_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def refresh_issues_table
    respond_to do |format|
      format.js
    end
  end
  
  def refresh_arch_decisions_table
    respond_to do |format|
      format.js
    end
  end
end
