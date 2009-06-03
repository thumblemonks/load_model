require 'thumblemonks/model_loader'

module ThumbleMonks #:nodoc:
  module LoadModel

    class RequiredRecordNotFound < ActiveRecord::RecordNotFound; end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods #:nodoc
      # A glorified before_filter that loads an instance of an ActiveRecord 
      # object as the result of searching for said object against a model 
      # defined by a given model name. The value of the HTTP request parameter 
      # :id will be used as the default lookup value. LoadModel will give you 
      # the ability to require an instance be found and/or override several 
      # other default behaviors.
      # 
      # Example
      #   class SillyFellowController < Application
      #     load_model :silly_fellow
      #     def action
      #       @silly_fellow.do_something
      #     end
      #   ens
      # 
      # You can require that a model instance be found for all actions or given 
      # actions. Default behavior is to not require that a model instance be 
      # found. When require is on and a record is not found, a 
      # ThumbleMonks::RequiredRecordNotFound Exception is thrown; which does
      # conveniently extend ActiveRecord::RecordNotFound.
      # 
      # To turn require on for all actions, simply pass _true_ to a provided
      # <em>:require</em> attribute, like so:
      # 
      # Example
      #   load_model :silly_fellow, :require => true
      # 
      # To turn require on for specific actions, pass an array of action names 
      # to <em>:require</em>. The model will be loaded for all actions, 
      # regardless of whether or not required is provided, but the exception 
      # will only be raised when an record is not found for the provided 
      # actions.
      # 
      # Example
      #   load_model :silly_fellow, :require => [:show, :update]
      # 
      # To use a different parameter key and model than the default, you can
      # provide the values in the :paramater_key and :class options (though not
      # necessary to provide them together), like the following:
      # 
      # Example
      #   load_model :foo, :class => :user, :parameter_key => :bar_id
      # 
      # In the above example, _load_model_ will assume the parameter_key is 
      # :bar_id while assuming the model's primary/foreign is still :id. For 
      # instance, the above example would result in a call like the following:
      # 
      #  @foo = User.find_by_id(params[:bar_id])
      # 
      # If you want to use a different lookup/foreign key than the default, you 
      # can also provide that key name using the :foreign_key parameter; like 
      # so:
      # 
      # Example
      #   load_model :foo, :class => :user, :parameter_key => :bar_id,
      #     :foreign_key => :baz_id
      # 
      # Which would result in a call similar to the following:
      # 
      #   @foo = User.find_by_baz_id(params[:bar_id])
      # 
      # If you want to only use load_model for some actions, you can still name 
      # them as you would with a before_filter using :only or :except. If you 
      # provide an :only and an :except value. :except will always win out over 
      # :only in the event of a collision.
      # 
      # Example
      #   load_model :foo, :only => [:show]
      #   load_model :bar, :except => [:create]
      #
      # == Through
      #
      # Load Model supports a :through option. With :through, you can 
      # load a model via the association of an existing loaded model. This is
      # especially useful for RESTful controllers.
      #
      # Example
      #   load_model :user, :require => true, :parameter_key => :user_id
      #   load_model :post, :through => :user
      #
      # In this example, a @post record will be loaded through the @user record
      # with essentially the following code:
      #
      #   @user.posts.find_by_id(params[:id])
      #
      # All of the previously mentioned options still apply (:parameter_key, 
      # :foreign_key, :require, :only, and :except) except for the :class 
      # option. Meaning you could really mess around!
      #
      # Example
      #   load_model :user, :require => true, :parameter_key => :user_id
      #   load_model :post, :through => :person, :parameter_key => :foo_id, 
      #     :foreign_key => :baz_id
      #
      # Would result in a call similar to the following:
      #
      #   @person.posts.find_by_baz_id(params[:foo_id])
      #
      # Require works as you would expect.
      #
      # If you would like load_model to not assume a pluralized association
      # name, you can provide the association name with the :association
      # option. Like so:
      #
      # Example
      #   class Person < ActiveRecord::Base
      #     has_many :blog_postings
      #   end
      #   class PostController < ActionController::Base
      #     load_model :post, :through => :person, :assocation => :blog_postings
      #   end
      #
      # == From
      #
      # Perhaps you don't need to do a subquery on a model's association and
      # you just need to load a model from another's belongs_to or has_one
      # association. This would be impossible in the above example. Instead,
      # will want to use the :from option. Like so:
      #
      # Example
      #   class Post < ActiveRecord::Base
      #     belongs_to :user
      #   end
      #   class PostController < ActionController::Base
      #     load_model :post
      #     load_model :user, :from => :post
      #   end
      #
      # The example is contrived, but you get the point. Essentially, this
      # would do the same as writing the following code:
      #
      # Example
      #   @post = Post.find_by_id(params[:id])
      #   @user = @post.user
      def load_model(name, opts={})
        unless loaders
          self.class_eval { before_filter :load_specified_models }
          write_inheritable_attribute(:loaders, [])
        end
        loaders << loader_class(opts).new(name, opts)
      end

      def loaders; self.read_inheritable_attribute(:loaders); end
    private
      def loader_class(opts)
        return ThumbleMonks::ThroughModelLoader if opts[:through]
        return ThumbleMonks::FromModelLoader if opts[:from]
        ThumbleMonks::AssociativeModelLoader
      end
    end # ClassMethods
  private
    def load_specified_models
      self.class.loaders.each do |loader|
        if loader.action_allowed?(action_name)
          obj = loader.load_model(self)
          raise RequiredRecordNotFound if obj.nil? && loader.action_required?(action_name)
          instance_variable_set(loader.assigns_to, obj)
        end
      end
    end # load_specified_models
  end # LoadModel
end # ThumbleMonks

ActionController::Base.send(:include, ThumbleMonks::LoadModel)