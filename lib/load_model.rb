module Glomp #:nodoc:
  module LoadModel

    class RequiredRecordNotFound < ActiveRecord::RecordNotFound; end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods #:nodoc
      # A glorified before_filter that loads an instance of an ActiveRecord 
      # object as# the result of searching for said object against a model 
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
      # Glomp::RequiredRecordNotFound Exception is thrown.
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
      # Finally, load_model supports a :through option. With :through, you can 
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
      # Require works as you would expect
      #
      # The only current caveat is that load_model assumes a has_many 
      # association exists on the :through model and is named in the pluralized 
      # form. In essence, in the above example, there is no way to tell 
      # load_model not look for the "posts" association. Perhaps a future 
      # change.
      #
      def load_model(name, opts={})
        unless loaders
          self.class_eval { before_filter :glomp_load_model_runner }
          write_inheritable_attribute(:loaders, [])
        end
        loader = opts[:through] ? ThroughModelLoader : ModelLoader
        loaders << loader.new(name, opts)
      end

      def loaders; self.read_inheritable_attribute(:loaders); end

      class ModelLoader #:nodoc
        attr_reader :assigns_to, :load_through, :parameter_key, :foreign_key,
          :except, :only, :requires

        def initialize(name, opts={})
          config = {:require => false, :parameter_key => :id,
            :foreign_key => :id, :class => name}.merge(opts)
          @assigns_to = "@#{name}".to_sym
          @load_through = config[:class].to_s.classify.constantize
          @parameter_key = config[:parameter_key].to_s
          @foreign_key = config[:foreign_key].to_s
          @requires = parse_required_actions(config[:require])
          @except = stringify_array(config[:except])
          @only = stringify_array(config[:only])
        end

        def action_allowed?(action)
          return false if except.include?(action)
          only.empty? ? true : only.include?(action)
        end

        def action_required?(action)
          requires == true || requires.include?(action)
        end
        
        def load_model(controller)
          begin
            lookup = parameter_value(controller)
            source(controller).send("find_by_#{foreign_key}", lookup)
          rescue ActiveRecord::StatementInvalid
            nil
          end
        end
      private
        def source(controller) load_through; end

        def parse_required_actions(actions)
          actions == true ? true : stringify_array(actions)
        end

        def parameter_value(controller) controller.params[parameter_key]; end

        def stringify_array(value) Array(value).map(&:to_s); end
      end # ModelLoader

      class ThroughModelLoader < ModelLoader #:nodoc
        attr_reader :load_through, :association
        def initialize(name, opts={})
          super(name, opts)
          @load_through = "@#{opts[:through]}".to_sym
          @association = name.to_s.pluralize
        end
      private
        def source(controller)
          controller.instance_variable_get(load_through).send(association)
        end
      end # ThroughModelLoader

    end # ClassMethods

  private

    def glomp_load_model_runner
      self.class.loaders.each do |loader|
        if loader.action_allowed?(action_name)
          obj = loader.load_model(self)
          if obj.nil? && loader.action_required?(action_name)
            raise RequiredRecordNotFound
          end
          instance_variable_set(loader.assigns_to, obj)
        end
      end
    end

  end # LoadModel
end # Glomp
