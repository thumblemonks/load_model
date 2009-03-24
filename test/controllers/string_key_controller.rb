class StringKeyController < ActionController::Base
  load_model 'user'
  load_model 'alternate', :parameter_key => 'alternate_id',
    :foreign_key => 'alternate_id'
  load_model 'chameleon', :class => 'user'

  def index; render :text => 'goodbye'; end
end
