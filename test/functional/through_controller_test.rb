require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/controller_helper'

class ThroughControllerTest < Test::Unit::TestCase
  def setup
    super
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @controller = ThroughController.new
    @user = User.create!(:name => 'Foo')
    @post = @user.posts.create!(:name => 'Foo post')
  end

  context "index with valid ids" do
    setup do
      get :index, :user_id => @user.id, :id => @post.id
    end
    
    should_assign_to :user, :equals => "@user"
    should_assign_to :post, :equals => "@post"
  end # with valid ids

  context "index with invalid post id" do
    setup do
      get :index, :user_id => @user.id, :id => -1
    end
    
    should_assign_to :user, :equals => "@user"
    should_not_assign_to :post
  end # with invalid post id

  context "show with alternative post via weird_id" do
    context "has exisiting records" do
      setup do
        get :show, :user_id => @user.id, :weird_id => @post.id
      end
    
      should_assign_to :user, :equals => "@user"
      should_assign_to :post, :equals => "@post"
    end # has existing records

    context "has nonexistant records for required action" do
      should "flail with exception" do
        assert_raise(Glomp::LoadModel::RequiredRecordNotFound) do
          get :show, :user_id => @user.id, :weird_id => -1
        end
      end
    end # has nonexistant records for required action
  end # show with alternative post via weird_id

end
