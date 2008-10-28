require File.dirname(__FILE__) + '/../test_helper'

class RestrictOptionsControllerTest < Test::Unit::TestCase

  def setup
    super
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @controller = RestrictOptionsController.new
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
