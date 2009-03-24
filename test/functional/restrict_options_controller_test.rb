require File.dirname(__FILE__) + '/../test_helper'

class RestrictOptionsController < ActionController::Base
  load_model :user, :only => [:index]
  load_model :alternate, :except => [:index], :parameter_key => :alternate_id,
    :foreign_key => :alternate_id

  def index; render :text => 'ran index'; end
  def show; render :text => 'ran show'; end
end

class RestrictOptionsControllerTest < ActionController::TestCase
  def setup
    @foo = User.create!(:name => 'Foo')
    @alt = Alternate.create!(:name => 'Bar', :alternate_id => 100)
  end

  def test_should_load_user_for_index
    get :index, :id => @foo.id, :alternate_id => @alt.id
    assert_equal @foo.id, assigns(:user).id
  end

  def test_should_not_load_alternate_for_index
    get :index, :id => @foo.id, :alternate_id => @alt.alternate_id
    assert_nil assigns(:alternate)
  end

  def test_should_load_alternate_for_show
    get :show, :id => @foo.id, :alternate_id => @alt.alternate_id
    assert_equal @alt, assigns(:alternate)
  end

  def test_should_not_load_user_for_show
    get :show, :id => @foo.id, :alternate_id => @alt.alternate_id
    assert_nil assigns(:user)
  end
end
