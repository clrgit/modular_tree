
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
    include NodeProperty
    def initialize(_arg) end
  end

  module InternalImplementation
    include Implementation
    def node = self
    def this = self
    def value = self
  end

  module ParentImplementation
    include ParentProperty
    include StemProperty
    include Implementation
  end

  module InternalParentImplementation
    include InternalImplementation
    include ParentImplementation

    attr_reader :parent
    alias_method :branch, :parent

    def initialize(parent) = @parent = parent

# protected
    attr_writer :parent
  end

  module ExternalParentImplementation
    include ParentImplementation
  end

  module ChildrenImplementation
    include ChildrenProperty
    include BranchesProperty
    include Implementation
# protected
    def attach(child) = abstract_method
  end

  module ExternalChildrenArrayImplementation
    include NodeProperty
    include ChildrenImplementation

    def node = array
    def this = array.first
    def value = array.first

    attr_accessor :array

    def children = @array.last.map(&:first)
    def branches = Enumerator.new { |enum| each_branch { |branch| enum << branch } }

    # FIXME: each_child/branch/etc. are actually map methods
    def each_child(&block) = @array.last.map { |*node| yield(*node) }
#   def each_child(&block) = array.second.each { |node| yield(*node, self) } # Actually possible
#   def each_child(&block) = array.last.each(&:first)

    def each_branch(&block)
      block_given? or raise ArgumentError
#     impl = self.class.new(nil)
      @array.last.map { |node| yield self.class.new(node) }
    end

    def each_edge(&block)
      @array.last.map { |node| yield self, self.class.new(node) }
    end

    def each(&block)
      @array.last.map.with_index { |node, i| yield i, self.class.new(node) }
    end

    def each_node(&block)
      @array.last.map.with_index { |node, i| yield self, i, self.class.new(node) }
    end

    def self.new(array)
      object = super(nil)
      object.array = array
      object
    end

# protected
    def attach(child) = array.last << child
  end

  module InternalChildrenImplementation
    include InternalImplementation
    include ChildrenImplementation

#   def children = abstract_method # Repeated here because provide_module is not executed yet
#   def each_child = abstract_method

#   alias_method :branches, :children
#   alias_method :each_branch, :each_child

    def branches = children
    def each_branch(&block) = each_child(&block)

    def attach(child) = abstract_method
  end

  # Demonstrates a linked list implementation
  module InternalChildrenListImplementation
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

# protected
    attr_writer :first_child
    attr_writer :next_sibling
  end

  module InternalChildrenArrayImplementation
    include InternalChildrenImplementation

    attr_reader :children

    def initialize(_parent)
      @children = []
      super
    end

    def each_child(&block) = @children.map(&block)
    def attach(child) = @children << child
  end

  module InternalChildrenHashImplementation
    include InternalChildrenImplementation

    attr_reader :hash

    def children = hash.values

    def initialize
      @hash = {}
      super
    end
  end

  module InternalParentChildImplementation
#   include InternalParentImplementation
#   include InternalChildrenImplementation
    include ParentProperty
    include ChildrenProperty

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

