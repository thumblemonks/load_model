class User < ActiveRecord::Base
  has_many :posts, :conditions => {:published => true}
  has_many :unpublished_posts, :conditions => {:published => false}, :class_name => 'Post'
end
