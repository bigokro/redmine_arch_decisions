class ArchMailer < Mailer  
  self.view_paths << File.dirname(__FILE__) + '/../app/views'

  def arch_decision_add(ad)
    redmine_headers 'Project' => ad.project.identifier,
                    'Arch-Decision-Id' => ad.id,
                    'Arch-Decision-Creator' => ad.created_by.login
    redmine_headers 'Arch-Decision-Assignee' => ad.assigned_to.login if ad.assigned_to
    recipients = ad.recipients
    cc = ad.watcher_recipients - @recipients
    subject = "[#{ad.project.name} - Arch Decision ##{ad.id}] (#{l(ad.status.name_key)}) #{ad.summary}"
    @arch_decision = ad
    @arch_decision_url = url_for(:controller => 'arch_decisions', :action => 'show', :id => ad, :project_id => ad.project)
    mail :to => recipients,
      :cc => cc,
      :subject => subject
  end

  def arch_decision_edit(ad)
    redmine_headers 'Project' => ad.project.identifier,
                    'Arch-Decision-Id' => ad.id,
                    'Arch-Decision-Creator' => ad.created_by.login
    redmine_headers 'Arch-Decision-Assignee' => ad.assigned_to.login if ad.assigned_to
    @author = ad.updated_by
    recipients = ad.recipients
    # Watchers in cc
    cc = ad.watcher_recipients - @recipients
    s = "[#{ad.project.name} - Arch Decision ##{ad.id}] "
    s << "(#{l(ad.status.name_key)}) "
    s << ad.summary
    subject = s
    @arch_decision => ad
    @arch_decision_url => url_for(:controller => 'arch_decisions', :action => 'show', :id => ad, :project_id => ad.project)
    mail :to => recipients,
      :cc => cc,
      :subject => subject
  end

  def arch_decision_discussion_add(add)
    redmine_headers 'Project' => discussion_project_id(add),
                    'Arch-Decision-Discussion-Id' => add.id,
                    'Arch-Decision-Discussion-Creator' => add.created_by.login
    recipients = add.recipients
    cc = add.watcher_recipients - @recipients
    subject = "[#{discussion_project_name(add)} - #{add.parent_type} ##{add.parent.id}] - New discussion comment added"
    @discussion = add
    @discussion_url = discussion_url(add)
    @parent_description = discussion_parent_description(add)
    mail :to => recipients,
      :cc => cc,
      :subject => subject
  end

  def arch_decision_discussion_edit(add)
    redmine_headers 'Project' => discussion_project_id(add),
                    'Arch-Decision-Discussion-Id' => add.id,
                    'Arch-Decision-Discussion-Creator' => add.created_by.login
    @author = add.created_by
    recipients = add.recipients
    # Watchers in cc
    cc = add.watcher_recipients - @recipients
    subject = "[#{discussion_project_name(add)} - #{add.parent_type} ##{add.parent.id}] - Discussion comment updated"
    @discussion = add
    @discussion_url = discussion_url(add)
    @parent_description = discussion_parent_description(add)
    mail :to => recipients,
      :cc => cc,
      :subject => subject
  end

  private

  def discussion_project_id(add)
    add.project.nil? ? "Redmine" : add.project.identifier
  end

  def discussion_project_name(add)
    add.project.nil? ? "Redmine" : add.project.name
  end

  def discussion_url(add)
    case add.parent
      when ArchDecision then url_for(:controller => 'arch_decisions', :action => 'show', :id => add.parent.id, :project_id => add.project)
      when Factor then url_for(:controller => 'factors', :action => 'show', :id => add.parent.id)
      when Strategy then url_for(:controller => 'strategies', :action => 'show', :id => add.parent.id)
      else url_for(:controller => 'projects') # Parent nil!
    end
  end
  
  def discussion_parent_description(add)
    description = case add.parent
      when ArchDecision then add.arch_decision.summary
      when Factor then add.factor.summary
      when Strategy then add.strategy.short_name
      else ""
    end
  end
end
