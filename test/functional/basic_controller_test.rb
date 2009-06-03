require File.dirname(__FILE__) + '/../test_helper'

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

class BasicControllerTest < ActionController::TestCase
  def setup
    @foo = User.create!(:name => 'Foo')
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

  should "find chameleon in users" do
    get :index, :id => @foo.id
    assert_equal @foo.id, assigns(:chameleon).id
  end

  should "not find chameleon in users with nonexistent id" do
    get :index, :id => (@foo.id + 1)
    assert_nil assigns(:chameleon)
  end

  should "not find record if key value is not an integer" do
    get :index, :id => 'abc'
    assert_nil assigns(:user)
  end

  context "when class name is constant" do
    should "find flamingo in user table" do
      get :index, :id => @foo.id
      assert_equal @foo.id, assigns(:flamingo).id
    end

    should "not find flamingo in user table" do
      get :index, :id => (@foo.id + 1)
      assert_nil assigns(:flamingo)
    end
  end # when class name is constant

  context "for alternate" do
    context "with existing id" do
      setup do
        @alt = Alternate.create!(:name => 'Alternate', :alternate_id => 100)
        get :index, :alternate_id => @alt.alternate_id
      end

      should_assign_to(:alternate) { @alt }
      should_assign_to(:tucan) { @alt }
    end

    context "with non-existant id" do
      setup { get :index, :alternate_id => 99 }
      should_not_assign_to(:alternate)
      should_not_assign_to(:tucan)
    end
  end # with alternate class and key

  context "when id is nil for users" do
    setup do
      User.expects(:find_by_id).never
      get :index, :id => ''
    end
  
    should_not_assign_to(:user)
  end # when parameter value is nil
end
