module ThumbleMonks #:nodoc:
  class NoModelLoaderFound < Exception; end

  class ModelLoader #:nodoc
    attr_reader :assigns_to, :except, :only, :requires

    def initialize(name, opts={})
      config = {:require => false}.merge(opts)
      @assigns_to = "@#{name}".to_sym
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
      raise NoModelLoaderFound
    end
  private
    def parse_required_actions(actions)
      actions == true ? true : stringify_array(actions)
    end

    def parameter_value(controller) controller.params[parameter_key]; end

    def stringify_array(value) Array(value).map(&:to_s); end
  end # ModelLoader

  class AssociativeModelLoader < ModelLoader #:nodoc
    attr_reader :load_through, :parameter_key, :foreign_key

    def initialize(name, opts={})
      super
      config = {:parameter_key => :id, :foreign_key => :id, :class => name}.merge(opts)
      @load_through = config[:class].to_s.classify.constantize
      @parameter_key = config[:parameter_key].to_s
      @foreign_key = config[:foreign_key].to_s
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
    def source(controller)
      load_through
    end
  end # AssociativeModelLoader

  class ThroughModelLoader < AssociativeModelLoader #:nodoc
    def initialize(name, opts={})
      super
      @load_through = "@#{opts[:through]}".to_sym
      @association = opts[:association] || name.to_s.pluralize
    end
  private
    def source(controller)
      controller.instance_variable_get(load_through).send(@association)
    end
  end # ThroughModelLoader

  class FromModelLoader < ModelLoader #:nodoc
    def initialize(name, opts={})
      super
      @load_from = "@#{opts[:from]}".to_sym
      @association = name.to_s
    end

    def load_model(controller)
      controller.instance_variable_get(@load_from).send(@association)
    end
  end # FromModelLoader

end # ThumbleMonks
