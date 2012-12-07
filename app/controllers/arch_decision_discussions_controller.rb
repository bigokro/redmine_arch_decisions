class ArchDecisionDiscussionsController < ApplicationController

  before_filter :load_discussion, :except => [:new, :preview]
  before_filter :load_parent, :only => [:new]
  before_filter :load_project
  before_filter :authorize

  helper :arch_decisions
  include ArchDecisionsHelper
  helper :attachments
  include AttachmentsHelper

  def show
  end


  def new
    @discussion = ArchDecisionDiscussion.new(params[:arch_decision_discussion])
    @discussion.factor = @factor
    @discussion.strategy = @strategy
    @discussion.arch_decision = @arch_decision if !(@factor || @strategy)
    if request.post?
      @discussion.created_by = User.current
      if @discussion.save
        save_attachments
        ArchDecisionsMailer.deliver_arch_decision_discussion_add(@discussion)
        flash[:notice] = l(:notice_successful_create)
      else
        flash[:error] = @discussion.errors.empty? ? l(:notice_create_discussion_failed) : @discussion.errors.full_messages.join("<br/>")
      end
    end
    redirect_to_show
  end


  def edit
    render_403 and return false unless @discussion.editable_by?(User.current)
    if request.post? && @discussion.update_attributes(params[:discussion])
      save_attachments
      ArchDecisionsMailer.deliver_arch_decision_discussion_edit(@discussion)
      flash[:notice] = l(:notice_successful_update)
      redirect_to_show
    end
  end

  def destroy
    render_403 and return false unless @discussion.destroyable_by?(User.current)
    if @discussion.destroy
      flash[:notice] = l(:notice_successful_delete)
    end
    redirect_to_show
  end

  def quote
    user = @discussion.created_by
    text = @discussion.content
    content = "#{ll(Setting.default_language, :text_user_wrote, user)}\\n> "
    content << text.to_s.strip.gsub(%r{<pre>((.|\s)*?)</pre>}m, '[...]').gsub('"', '\"').gsub(/(\r?\n|\r\n?)/, "\\n> ") + "\\n\\n"
    render(:update) { |page|
      page.<< "$('discussion_subject').value = \"#{@discussion.subject}\";"
      page.<< "$('discussion_content').value = \"#{content}\";"
      page << "showForm('new_discussion');"
      page << "Form.Element.focus('discussion_content');"
      page << "Element.scrollTo('new_discussion_form_row');"
      page << "$('discussion_content').scrollTop = $('discussion_content').scrollHeight - $('discussion_content').clientHeight;"
    }
  end
  
  def preview
    discussion = ArchDecisionDiscussion.find(params[:id]) if params[:id]
    @attachments = @discussion.attachments if discussion
    @text = params[:discussion][:content]
    render :partial => 'common/preview'
  end

  private 

  def load_discussion
    @discussion = ArchDecisionDiscussion.find(params[:id])
    @arch_decision = @discussion.arch_decision
    @factor = @discussion.factor
    @strategy = @discussion.strategy
  end

  def load_project
    @project = Project.find(get_id_from_params("project")) if get_id_from_params("project")
    @project = @discussion.project if @project.nil? && @discussion
  end

  # Although it tries all, only one of these should be loaded
  def load_parent
    @arch_decision = ArchDecision.find(get_id_from_params("arch_decision")) if get_id_from_params("arch_decision")
    @factor = Factor.find(get_id_from_params("factor")) if get_id_from_params("factor")
    @strategy = Strategy.find(get_id_from_params("strategy")) if get_id_from_params("strategy")
  end

  def redirect_to_show
    if !@strategy.nil?
      redirect_to( :controller => "strategies",
                    :action => 'show',
                    :id => @strategy.id )
    elsif !@factor.nil?
      redirect_to( "/factors/show/#{@project.id}/#{@factor.id}" )
    elsif !@arch_decision.nil?
      redirect_to( :controller => "arch_decisions",
                    :action => 'show',
                    :project_id => @project.id,
                    :id => @arch_decision.id )
    else
      render :action => 'show'
    end
  end

  def get_id_from_params(type)
    params[type + "_id"] ? params[type + "_id"] : (params[:discussion] ? params[:discussion][type + "_id"] : nil)
  end

  def save_attachments
    # test for backwards-compatibility
    defined?(attach_files) ? attach_files(@discussion, params[:attachments]) : Attachment.attach_files(@discussion, params[:attachments])
  end

end
