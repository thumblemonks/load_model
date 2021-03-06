require File.dirname(__FILE__) + '/../test_helper'

class FromController < ActionController::Base
  load_model :post
  load_model :user, :from => :post
  load_model :foo, :from => :post

  def index; render :text => 'index'; end
end

class FromControllerTest < ActionController::TestCase
  def setup
    @user = User.create!(:name => 'Foo')
    @post = @user.posts.create!(:name => 'Foo post')
  end

  context "loading from post model" do
    setup do
      get :index, :id => @post.id
    end

    should_assign_to(:post) { @post }
    should_assign_to(:user) { @user }
    should_assign_to(:foo) { "bar" }
  end
end
