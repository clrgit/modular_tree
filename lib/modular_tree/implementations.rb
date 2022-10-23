module Tree
  module ParentImplementation
    include Tracker
    provide_module ParentProperty

    attr_reader :parent

    def initialize(parent) = @parent = parent

  protected
    attr_writer :parent
  end

  module ChildrenImplementation
    include Tracker
    abstract_module
    provide_module ChildrenProperty

  protected
    def attach(child) = abstract_method
  end

  # Not tested atm. Demonstrates a linked list implementation
  module ListImplementation
    include ChildrenImplementation

    attr_reader :first_child
    attr_reader :next_sibling

    def children
      n = self.first_child
      a = [n]
      a << n while n = n.first_sibling
      a
    end

    def attach(child)
      child.instance_variable_set(:@next_sibling, first_child)
      @first_child = child
    end

  protected
    attr_writer :first_child
    attr_writer :next_sibling
  end

  module ArrayImplementation
    include Tracker
    provide_module ChildrenProperty, ChildrenImplementation

    attr_reader :children

    def initialize(_parent)
#     puts "ArrayImplementation#initialize"
      @children = []
#     puts self.class.ancestors
      super
    end

    def attach(child)
#     puts "ArrayImplementation#attach(#{child})"
      @children << child
    end
  end

  module HashImplementation
    include ChildrenImplementation

    attr_reader :hash

    def children = hash.values

    def initialize
      @hash = {}
      super
    end
  end

  module ParentChildImplementation
    include Tracker
    require_module ParentImplementation, ChildrenImplementation

    def initialize(parent)
      super
      parent&.attach(self)
    end

    def attach(child)
      super(child)
      child.send(:parent=, self)
    end
  end
end
