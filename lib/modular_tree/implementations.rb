
# TODO TODO TODO IDEA 
#
# External trees
#   node/branch/branches
#     returns tree
#
#   this/parent/children
#     returns data field
#
# Internal trees
#   Unifies node and this
#
# Both of internal and external trees have branch/branches relations. 
#
# Internal trees adds a parent/children relation
#
#
#
# Only internal trees have parent/child relations. External trees have only branch/branches relations

module Tree
  module Implementation
    include Tracker
    abstract_module

    provide_module NodeProperty
  end

  module InternalImplementation
    include Tracker
    abstract_module
    provide_module NodeProperty
    
    def node = self
  end

  module ParentImplementation
    include Tracker
    include Implementation

    abstract_module
    provide_module BranchProperty
    provide_module ParentProperty
  end

  module InternalParentImplementation
    include Tracker
    include InternalImplementation
    include ParentImplementation

    attr_reader :parent
    alias_method :branch, :parent

    def initialize(parent) = @parent = parent

  protected
    attr_writer :parent
  end

  module ExternalParentImplementation
    include Tracker
    include ParentImplementation

    abstract_module
  end

  module ChildrenImplementation
    include Tracker
    include Implementation

    abstract_module
    provide_module ChildrenProperty
    provide_module BranchesProperty

  protected
    def attach(child) = abstract_method
  end

  module ExternalArrayImplementation
    include Tracker
    include ChildrenImplementation

    provide_module NodeProperty

    attr_accessor :array # Initialized where?

    attr_accessor :nodes # Array of nodes. Aka. 'children'


    def this = array.first

    def children = array.second.map(&:first)
    def branches = Enumerator.new { |enum| each_branch { |branch| enum << branch } }

    def each_child(&block) = array.second.each { |*node| yield(*node) }

#   def each_child(&block) = array.second.each { |node| yield(*node, self) } # Actually possible

    def each_child(&block) = array.second.each(&:first)

    def each_branch(&block)
      impl = self.new
      array.second.map { |node|
        impl.array = node
        yield impl
      }
    end

    def self.new(array)
      object = super(nil)
      object.array = array
      object
    end

  protected
    def attach(child) = array.last << child
  end

  module InternalChildrenImplementation
    include Tracker
    include InternalImplementation
    include ChildrenImplementation

    def children = abstract_method # Repeated here because provide_module is not executed yet
    def each_child = abstract_method

    alias_method :branches, :children
    alias_method :each_branch, :each_child
  end

  # Demonstrates a linked list implementation
  module ListImplementation
    include Tracker
    include InternalChildrenImplementation

    attr_reader :first_child
    attr_reader :next_sibling

    def children
      n = self.first_child or return []
      a = [n]
      a << n while n = n.next_sibling
      a
    end

    def each_child(&block)
      curr = first_child or return
      yield(curr)
      yield curr while curr = next_sibling
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
    include InternalChildrenImplementation

    attr_reader :children

    def initialize(_parent)
      @children = []
      super
    end

    def each_child(&block) = @children.each(&block)

    def attach(child) = @children << child
  end

  module HashImplementation
    include InternalChildrenImplementation

    attr_reader :hash

    def children = hash.values

    def initialize
      @hash = {}
      super
    end
  end

  module ParentChildImplementation
    include Tracker
    require_module ParentImplementation, InternalChildrenImplementation

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

