class RequireModelController < ActionController::Base
  load_model :stuser, :class => :alternate, :parameter_key => :alternate_id,
    :foreign_key => :alternate_id, :require => nil # never required
  load_model :fuzzle, :parameter_key => :fuzzle_id, :foreign_key => :fuzzle_id,
    :require => [:newer] # required for newer action
  load_model :user, :require => true # required for all actions

  def index; render :text => 'whatever'; end
  def new; render :text => 'whatever 2'; end
  def newer; render :text => 'whatever 3'; end
end
