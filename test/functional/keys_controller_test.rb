require File.dirname(__FILE__) + '/../test_helper'

class KeysController < ActionController::Base
  # Expects to use fuzzle_id as parameter key against User class with FK of :id
  load_model :user, :parameter_key => :fuzzle_id

  # Expects to use :fuzzle_id as FK and parameter key against Fuzzle class 
  # (normal operation)
  load_model :fuzzler, :parameter_key => :fuzzle_id, :foreign_key => :fuzzle_id,
    :class => :fuzzle

  def index; render :text => 'hello'; end
end

class KeysControllerTest < ActionController::TestCase
  def setup
    @user = User.create!(:name => 'Foo')
    @fuzzler = Fuzzle.create!(:name => 'Bar', :fuzzle_id => 300)
  end

  def test_should_find_user_using_fuzzle_id_as_param_key
    get :index, :fuzzle_id => @user.id
    assert_equal @user.id, assigns(:user).id
    assert_nil assigns(:fuzzler)
  end

  def test_should_find_fuzzler_using_fuzzle_id_as_param_and_foreign_key
    get :index, :fuzzle_id => @fuzzler.fuzzle_id
    assert_equal @fuzzler.id, assigns(:fuzzler).id
    assert_nil assigns(:user)
  end
end
