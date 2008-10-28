ENV["RAILS_ENV"] = "test"
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
require 'test_help'
load(File.dirname(__FILE__) + "/../db/schema.rb")

class User < ActiveRecord::Base
  has_many :posts
end
class Post < ActiveRecord::Base
  belongs_to :user
end
class Alternate < ActiveRecord::Base; end
class Fuzzle < ActiveRecord::Base; end

class Test::Unit::TestCase
  def teardown
    Fuzzle.delete_all
    Alternate.delete_all
    Post.delete_all
    User.delete_all
  end
end

require File.dirname(__FILE__) + '/functional/controller_helper'
