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
class BasicController; def rescue_action(e) raise e end; end

# Has strings for values

class StringKeyController < ActionController::Base
  load_model 'user'
  load_model 'alternate', :parameter_key => 'alternate_id',
    :foreign_key => 'alternate_id'
  load_model 'chameleon', :class => 'user'

  def index; render :text => 'goodbye'; end
end
class StringKeyController; def rescue_action(e) raise e end; end

# Requires values

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
class RequireModelController; def rescue_action(e) raise e end; end

# Restriction options

class RestrictOptionsController < ActionController::Base
  load_model :user, :only => [:index]
  load_model :alternate, :except => [:index], :parameter_key => :alternate_id,
    :foreign_key => :alternate_id

  def index; render :text => 'ran index'; end
  def show; render :text => 'ran show'; end
end
class RequireModelController; def rescue_action(e) raise e end; end

class KeysController < ActionController::Base
  # Expects to use fuzzle_id as parameter key against User class with FK of :id
  load_model :user, :parameter_key => :fuzzle_id

  # Expects to use :fuzzle_id as FK and parameter key against Fuzzle class 
  # (normal operation)
  load_model :fuzzler, :parameter_key => :fuzzle_id, :foreign_key => :fuzzle_id,
    :class => :fuzzle

  def index; render :text => 'hello'; end
end
class KeysController; def rescue_action(e) raise e end; end

# Load model through existing model
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
class ThroughController; def rescue_action(e) raise e end; end
