
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
    def node_value = self
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

  module InternalRootImplementation
    include RootProperty
    include InternalParentImplementation
    def root = @root ||= parent&.root || self
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
    def node_value = array.first # FIXME What is this? It is a problem several places

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

  # TODO: A ChildrenArrayImplementation that defines #insert and #append and
  # adds an optional index argument to #attach

  module InternalChildrenArrayImplementation
    include InternalChildrenImplementation

    attr_reader :children

    def initialize(_parent)
      @children = []
      super
    end

    def each_child(&block) = @children.map(&block)

    def attach(child) = @children << child
    def detach(arg)
      key = arg.is_a?(Integer) ? arg : @children.index(arg)
      child = @children.delete_at(key) or raise ArgumentError, "Can't find object"
      child.send(:instance_variable_set, :@parent, nil)
      child
    end

    # Can be used with any array implementation. +where+ is either an Integer
    # index or an object
    #
    # TODO: Rename #attach. #insert & #append are Enumerable operations
    def insert(where, child) = insert_append(:insert, where, child)
    def append(where, child) = insert_append(:append, where, child)

    def replace(where, *children)
      children = Array(children).flatten
      case where
        when Integer
          subject = @children[where] or raise ArgumentError
          index = where
        else
          subject = where
          index = @children.index(where) or raise ArgumentError
      end
      @children = @children[0...index] + children + @children[index + 1..-1]
      subject
    end

  protected
    def insert_append(which, where, child)
      if !where.is_a?(Integer)
        where = @children.index(where) or raise ArgumentError, "Can't find object"
      end
      where += 1 if which == :append
      @children.insert(where, child)
    end
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

  module InternalParentChildArrayImplementation
    include InternalParentChildImplementation

    def insert(where, child)
      super
      child.send(:parent=, self)
    end

    def append(where, child)
      super
      child.send(:parent=, self)
    end

    # Requires that Child classes already has defined this
    def replace(where, *children)
      children = Array(children).flatten
      subject = super(where, children)
      subject.send(:parent=, nil)
      children.each { |child| child.send(:parent=, self) }
      subject
    end
  end
end

