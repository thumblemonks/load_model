# Load Model

A glorified before_filter that loads an instance of an `ActiveRecord` object as the result of searching for said object against a model defined by a given model name. The value of the HTTP request parameter `:id` will be used as the default lookup value. `LoadModel` will give you the ability to require an instance be found and/or override several other default behaviors.

    class SillyFellowController < Application
      load_model :silly_fellow
      def action
        @silly_fellow.do_something
      end
    end

You can require that a model instance be found for all actions or given actions. Default behavior is to not require that a model instance be found. When require is on and a record is not found, a `ThumbleMonks::RequiredRecordNotFound` Exception is thrown; which extends from ActiveRecord::RecordNotFound, for your convenience.

To turn require on for all actions, simply pass *true* to a provided `:require` attribute, like so:

    load_model :silly_fellow, :require => true

To turn require on for specific actions, pass an array of action names to  `:require`. The model will be loaded for all actions, regardless of whether or not required is provided, but the exception will only be raised when an record is not found for the provided actions.

    load_model :silly_fellow, :require => [:show, :update]

To use a different parameter key and model than the default, you can provide the values in the `:paramater_key` and `:class` options (though not necessary to provide them together), like the following:

    load_model :foo, :class => :user, :parameter_key => :bar_id

In the above example, `load_model` will assume the parameter_key and the model's primary/foreign key are both the same. For instance, the above example would result in a call like the following:

    @foo = User.find_by_bar_id(params[:bar_id])

If you want to use a different lookup/foreign key than the default, you can also provide that key name using the `:foreign_key` parameter; like so:

    load_model :foo, :class => :user, :parameter_key => :bar_id,
      :foreign_key => :baz_id

Which would result in a call similar to the following:

    @foo = User.find_by_baz_id(params[:bar_id])

If you want to only use `load_model` for some actions, you can still name them as you would with a `before_filter` using `:only` or `:except`. If you provide an `:only` and an `:except` value. `:only` will always win out over `:except` when there are collisions (i.e. you provide both in the same call)

    load_model :foo, :only => [:show]
    load_model :bar, :except => [:create]

### Through

Load Model supports a :through option. With :through, you can load a model via the association of an existing loaded model. This is especially useful for RESTful controllers.

    load_model :user, :require => true, :parameter_key => :user_id
    load_model :post, :through => :user

In this example, a @post record will be loaded through the @user record with essentially the following code:

    @user.posts.find_by_id(params[:id])

All of the previously mentioned options still apply (:parameter_key, :foreign_key, :require, :only, and :except) except for the :class option. Meaning you could really mess around!

    load_model :user, :require => true, :parameter_key => :user_id
    load_model :post, :through => :person, :parameter_key => :foo_id, 
      :foreign_key => :baz_id

Would result in a call similar to the following:

    @person.posts.find_by_baz_id(params[:foo_id])

Require works as you would expect.

If you would like load_model to not assume a pluralized association name, you can provide the association name with the :association option. Like so:

    class Person < ActiveRecord::Base
      has_many :blog_postings
    end
    
    class PostController < ActionController::Base
      load_model :post, :through => :person, :assocation => :blog_postings
    end

### From

Perhaps you don't need to do a subquery on a model's association and you just need to load a model from another's `belongs_to` or `has_one` association. This would be impossible in the above example. Instead, will want to use the :from option. Like so:

    class Post < ActiveRecord::Base
      belongs_to :user
    end
    
    class PostController < ActionController::Base
      load_model :post
      load_model :user, :from => :post
    end

The example is contrived, but you get the point. Essentially, this would do the same as writing the following code:

    @post = Post.find_by_id(params[:id])
    @user = @post.user

## Installation

    sudo gem install thumblemonks-load_model

## Requirements

1. Ruby 1.8.6 or higher
2. Rails 2.x or higher

## Acknowledgements

Anyone who developed, discussed, or any other way participated in HTTP, REST, and Rails.

## Contact

Justin Knowlden <gus@gusg.us>

## License

See MIT-LICENSE
