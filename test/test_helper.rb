ENV["RAILS_ENV"] = "test"
ENV["RAILS_ROOT"] = File.expand_path(File.join(File.dirname(__FILE__), '..', 'test', 'rails'))
require File.expand_path(File.join(ENV["RAILS_ROOT"], 'config', 'environment'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'load_model'))
require 'test_help'
load(File.join(ENV["RAILS_ROOT"], "db", "schema.rb"))

class User < ActiveRecord::Base
  has_many :posts, :conditions => {:published => true}
  has_many :unpublished_posts, :conditions => {:published => false}, :class_name => 'Post'
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
