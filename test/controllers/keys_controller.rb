class KeysController < ActionController::Base
  # Expects to use fuzzle_id as parameter key against User class with FK of :id
  load_model :user, :parameter_key => :fuzzle_id

  # Expects to use :fuzzle_id as FK and parameter key against Fuzzle class 
  # (normal operation)
  load_model :fuzzler, :parameter_key => :fuzzle_id, :foreign_key => :fuzzle_id,
    :class => :fuzzle

  def index; render :text => 'hello'; end
end
