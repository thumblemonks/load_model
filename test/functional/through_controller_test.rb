require File.dirname(__FILE__) + '/../test_helper'

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

class ThroughControllerTest < ActionController::TestCase
  def setup
    @user = User.create!(:name => 'Foo')
    @post = @user.posts.create!(:name => 'Foo post')
  end

  context "index with valid ids" do
    setup do
      get :index, :user_id => @user.id, :id => @post.id
    end
    
    should_assign_to(:user) { @user }
    should_assign_to(:post) { @post }
  end # with valid ids

  context "show_unpublished with valid id" do
    setup do
      @unpublished_post = @user.posts.create!{ |p| p.published = false }
      get :show_unpublished, :user_id => @user.id, :id => @unpublished_post.id
    end
    
    should_assign_to(:user) { @user }
    should_assign_to(:post) { @unpublished_post }
  end
  
  context "index with invalid post id" do
    setup do
      get :index, :user_id => @user.id, :id => -1
    end
    
    should_assign_to(:user) { @user }
    should_not_assign_to :post
  end # with invalid post id

  context "show with alternative post via weird_id" do
    context "has exisiting records" do
      setup do
        get :show, :user_id => @user.id, :weird_id => @post.id
      end
    
      should_assign_to(:user) { @user }
      should_assign_to(:post) { @post }
    end # has existing records

    context "has nonexistent records for required action" do
      should "flail with exception" do
        assert_raise(ThumbleMonks::LoadModel::RequiredRecordNotFound) do
          get :show, :user_id => @user.id, :weird_id => -1
        end
      end
    end # has nonexistant records for required action
  end # show with alternative post via weird_id
end
