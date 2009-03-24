class RestrictOptionsController < ActionController::Base
  load_model :user, :only => [:index]
  load_model :alternate, :except => [:index], :parameter_key => :alternate_id,
    :foreign_key => :alternate_id

  def index; render :text => 'ran index'; end
  def show; render :text => 'ran show'; end
end
