require File.dirname(__FILE__) + '/../test_helper'

class LoadModelTest < Test::Unit::TestCase

  def setup
    super
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @controller = BasicController.new
    @foo = User.create!(:name => 'Foo')
  end

  def teardown
    Alternate.delete_all
    User.delete_all
  end

  context "when parameter" do
    context "is provided" do
      setup { get :index, :id => @foo.id }
      should("find record") { assert_equal @foo.id, assigns(:user).id }
    end # is provided

    context "is not provided" do
      setup { get :index }
      should("not assign any record") { assert_nil assigns(:user) }
    end # is not provided

    context "does not match existing record" do
      setup { get :index, :id => (@foo.id + 1) }
      should("not assign any record") { assert_nil assigns(:user) }
    end # does not match existing record
  end # when parameter

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

  def test_should_find_flamingo_in_user_table_even_when_class_name_is_constant
    get :index, :id => @foo.id
    assert_equal @foo.id, assigns(:flamingo).id
  end

  def test_should_not_find_flamingo_in_user_table_when_class_name_is_constant
    get :index, :id => (@foo.id + 1)
    assert_nil assigns(:flamingo)
  end

  def test_should_find_tucan_in_users_with_alternate_class_and_key
    alt = Alternate.create!(:name => 'Alternate', :alternate_id => 100)
    get :index, :alternate_id => alt.alternate_id
    assert_equal alt.id, assigns(:tucan).id
  end

  def test_should_not_find_tucan_in_users_with_alternate_class_and_key
    alt = Alternate.create!(:name => 'Alternate', :alternate_id => 100)
    get :index, :alternate_id => (alt.alternate_id + 1)
    assert_nil assigns(:tucan)
  end

  def test_should_not_find_record_if_key_value_is_not_an_integer
    get :index, :id => 'abc'
    assert_nil assigns(:user)
  end

end
