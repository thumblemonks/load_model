class ThroughController < ActionController::Base
  load_model :user, :parameter_key => :user_id
  load_model :post, :through => :user, :except => [:show]
  # proving that except and only work
  load_model :post, :through => :user, :parameter_key => 'weird_id',
    :require => true, :only => [:show]

  load_model :post, :through => :user, :association => :unpublished_posts,
    :require => true, :only => [:show_unpublished]
      
  def index; render :text => 'index'; end
  def show; render :text => 'show'; end
  def show_unpublished; render :text => 'unpublished'; end
end
