class BasicController < ActionController::Base
  load_model :user
  load_model :alternate, :parameter_key => :alternate_id,
    :foreign_key => :alternate_id
  load_model :chameleon, :class => :user
  load_model :flamingo, :class => User
  load_model :tucan, :class => :alternate, :parameter_key => :alternate_id,
    :foreign_key => :alternate_id

  def index; render :text => 'hello'; end
end
