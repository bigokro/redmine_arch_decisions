module ArchDecisionsHelper

  def autotab
    @current_tab ||= 0
    @current_tab += 1
  end

end
