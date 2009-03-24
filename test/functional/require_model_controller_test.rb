require File.dirname(__FILE__) + '/../test_helper'

class RequireModelControllerTest < ActionController::TestCase
  def setup
    @foo = User.create!(:name => 'Foo')
  end

  def test_should_find_record_if_required_to_find_record_and_record_is_found
    get :index, :id => @foo.id
    assert_equal @foo.id, assigns(:user).id
  end

  def test_should_not_require_value_if_required_is_nil
    get :new, :id => @foo.id
    assert_equal @foo.id, assigns(:user).id
  end

  def test_should_not_require_value_if_required_is_for_different_action
    fuzz = Fuzzle.create!(:name => 'Fuzzy', :fuzzle_id => 200)
    get :new, :id => @foo.id, :fuzzle_id => fuzz.id
    assert_equal @foo.id, assigns(:user).id
    assert_nil assigns(:stuser)
    assert_nil assigns(:fuzzle)
  end

  def test_should_raise_error_if_required_is_scoped_and_record_not_found
    fuzz = Fuzzle.create!(:name => 'Fuzzy', :fuzzle_id => 200)
    assert_raise(ThumbleMonks::LoadModel::RequiredRecordNotFound) do
      get :newer, :id => @foo.id, :fuzzle_id => (fuzz.id + 1)
    end
  end

  def test_should_raise_error_if_required_is_true_and_record_not_found
    assert_raise(ThumbleMonks::LoadModel::RequiredRecordNotFound) do
      get :new, :id => (@foo.id + 1)
    end
  end
end
