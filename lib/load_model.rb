# LoadModel
module Glomp #:nodoc:
  module LoadModel #:nodoc

    class RequiredRecordNotFound < Exception; end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods #:nodoc
      # Loads an instance matching the model name with the result of searching 
      # for an object against a model defined by the provided model name. The 
      # parameter :id will be used by default. load_model will also require that 
      # the value of the id be an integer.
      #
      # Example
      #   load_model :silly_fellow
      #   def action
      #     @silly_fellow.do_something
      #   end
      #
      # You can also require that a model instance be found for all actions or 
      # given actions. Default behavior is to not require that a model instance 
      # be found. When require is on and a record is not found, the 
      # RequiredRecordNotFound Exception is thrown.
      #
      # To require for all actions, simply pass _true_ to <em>:require</em>
      #
      # Example
      #   load_model :silly_fellow, :require => true
      #
      # To require for specific actions, pass an array of action names to 
      # <em>:require</em>. The model will be loaded for all actions, regardless 
      # of whether or not required is provided.
      #
      # Example
      #   load_model :silly_fellow, :require => [:show, :update]
      #
      # To use a different parameter key and Model than the default, you can 
      # provide the values in the :paramater_key and :class options, like the
      # following:
      #
      # Example
      #  load_model :foo, :class => :user, :parameter_key => :bar_id
      #
      # In the above example, _load_model_ will assume the parameter_key and the
      # model's lookup key are both the same. For instance, the above example
      # would result in a call like the following:
      #
      #  @foo = User.find_by_bar_id(params[:bar_id])
      #
      # However, if you want to use a different lookup key, you can also provide
      # that key name using the :foreign_key parameter; like so:
      #
      # Example
      #  load_model :foo, :class => :user, :parameter_key => :bar_id,
      #    :foreign_key => :id
      #
      # Which would result in a call similar to the following:
      #
      #  @foo = User.find_by_id(params[:bar_id])
      #
      # If you want to only use load_model for some actions, you can still name 
      # them as you would with a before_filter using :only or :except. If you 
      # provide an :only and an :except value. :only will always win out over
      # :except when there are collisions (i.e. you provide both in the same 
      # call)
      #
      # Example
      #  load_model :foo, :only => [:show]
      #  load_model :bar, :except => [:create]
      #
      def load_model(name, opts={})
        unless loaders
          self.class_eval do
            before_filter :glomp_load_model_runner
          end
          write_inheritable_attribute(:loaders, [])
        end
        loaders << ModelLoader.new(name, opts)
      end

      def loaders
        self.read_inheritable_attribute(:loaders)
      end

      class ModelLoader #:nodoc
        def initialize(name, opts={})
          config = {:require => false, :parameter_key => :id,
            :class => name}.merge(opts)
          config[:foreign_key] ||= config[:parameter_key]
          @ivar = "@#{name}".to_sym
          @klass = config[:class].to_s.classify.constantize
          @param_key = config[:parameter_key].to_s
          @foreign_key = config[:foreign_key].to_s
          @requires = parse_required_actions(config[:require])
          @except = opts[:except].to_a.map{|a| a.to_s}
          @only = opts[:only].to_a.map{|a| a.to_s} #- @except
        end

        def process(controller)
          action = action_name(controller)
          if processable?(action)
            key_value = controller.params[@param_key.to_sym]
            obj = nil
            if key_value.to_s =~ /^[0-9]+$/
              obj = @klass.send("find_by_#{@foreign_key}".to_sym, key_value)
              controller.instance_variable_set(@ivar, obj)
            end
            if required?(action) && obj.nil?
              raise RequiredRecordNotFound
            end
          end
        end
      private
        def parse_required_actions(requires)
          requires = nil if requires == false
          requires = requires.to_a.map {|a| a.to_s} unless requires == true
          requires
        end

        def action_name(controller)
          controller.action_name
        end

        def processable?(action)
          processable = !@except.include?(action)
          processable = @only.include?(action) unless @only.empty?
          processable
        end

        def required?(action)
          @requires == true || @requires.include?(action)
        end
      end # ModelLoader

    end # ClassMethods

  private

    def glomp_load_model_runner
      self.class.loaders.each { |loader| loader.process(self) }
    end

  end # LoadModel
end # Glomp
