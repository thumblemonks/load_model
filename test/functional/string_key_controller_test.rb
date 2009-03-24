require File.dirname(__FILE__) + '/../test_helper'

class StringKeyControllerTest < ActionController::TestCase
  def setup
    @foo = User.create!(:name => 'Foo')
  end

  def test_should_find_record_and_assign_to_instance_variable_if_param_provided
    get :index, :id => @foo.id
    assert_equal @foo.id, assigns(:user).id
  end

  def test_should_return_nil_if_expected_param_not_provided
    get :index
    assert_nil assigns(:user)
  end

  def test_should_return_nil_if_expected_param_does_not_match_record
    get :index, :id => (@foo.id + 1) # Should not belong to an existing user
    assert_nil assigns(:user)
  end

  def test_should_find_record_with_alternate_id_as_expected_param_key
    alt = Alternate.create!(:name => 'Alternate', :alternate_id => 100)
    get :index, :alternate_id => alt.alternate_id
    assert_equal alt.id, assigns(:alternate).id
    assert_equal alt.alternate_id, assigns(:alternate).alternate_id
  end

  def test_should_find_nothing_when_alternate_id_does_not_match_record
    alt = Alternate.create!(:name => 'Alternate', :alternate_id => 99)
    get :index, :alternate_id => 100
    assert_nil assigns(:alternate)
  end

  def test_should_find_chameleon_in_user_table
    get :index, :id => @foo.id
    assert_equal @foo.id, assigns(:chameleon).id
  end

  def test_should_not_find_chameleon_in_user_table_with_nonexistent_id
    get :index, :id => (@foo.id + 1)
    assert_nil assigns(:chameleon)
  end
end
