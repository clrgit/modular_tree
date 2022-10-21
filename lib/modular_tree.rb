require 'abstract_method_error'

require 'constrain'
include Constrain

require 'forward_to'
include ForwardTo

require_relative "modular_tree/version"
require_relative "modular_tree/separator"
require_relative "modular_tree/filter"
require_relative "modular_tree/pairs"
require_relative "modular_tree/algorithms"

module Tree
  module NodeParent
    def parent = abstract_method
  end

  module NodeChildren
    def children = abstract_method
  end

  module NodeKey # Set
    def key = abstract_method
  end

  module NodeKeys # Map
    def keys = abstract_method
    def key?(k) = keys.include? k
    def [](key) = abstract_method
  end

  module NodePath
    DEFAULT_SEPARATOR = "."

    include NodeKey
    include UpTreeAlgorithms

    def separator = @separator ||= parent&.separator || DEFAULT_SEPARATOR
    def separator=(sep) @separator = sep end

    def path = @path ||= ancestry[1..-1]&.map(&:key)&.join(separator) || ""
    def uid() @uid ||= [parent&.uid, key].compact.join(separator) end
  end

  module NodeDot
    include NodeKeys
    include Separator

    def dot(path) = Separator.split(path).keys.each.inject(self) { |a,e| a[e] }
  end

  module NodeRoot
    include NodeParent

    def root = @root ||= parent&.root
  end

  module NodePool
    include NodePath

    def self.included(other)
      other.instance_variable_set(:@pool, {})
      other.extend(ClassMethods)
    end

    def initialize(*args)
      puts "NodePool#initialize"
      super(*args)
      p self.uid
      self.class[self.uid] = self
    end

    module ClassMethods
      def key?(uid) = @pool.key?(uid)
      def keys = @pool.keys
      def nodes = @pool.values
      def [](uid) = @pool[uid]
      def []=(uid, node) @pool[uid] = node end
    end
  end

  module ParentImplementation
    include NodeParent
    attr_reader :parent
    def initialize(parent)
#     puts "ParentImplementation#initialize"
      @parent = parent
      super()
    end
  end

  module ChildrenImplementation
    include NodeChildren
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
  end

  module ArrayImplementation
    include ChildrenImplementation
    attr_reader :array
    alias_method :children, :array
    def initialize
      puts "ArrayImplementation#initialize"
      @array = []
      super
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
    include ParentImplementation
    include ChildrenImplementation

    def initialize(parent)
      puts "ParentChildImplementation#initialize"
      super(parent)
      parent&.attach(self)
    end

  protected
    def attach(child)
      children << child
      child.instance_variable_set(:@parent, self)
    end
  end

# module UpTreeAlgorithms
#   def self.included(other)
#     super
#     puts "-----------------"
#     p other.ancestors.include? ParentImplementation
#     p other.ancestors
#     puts "-----------------"
#   end
# end

  class AbstractTree
    def empty? = abstract_method
    def size = abstract_method
  end

  # A regular tree. Users of this library should derived their base node class
  # from Tree
  #
  class Tree < AbstractTree # Aka. SetTree aka. ArrayTree
    include ParentImplementation
    include ArrayImplementation
    include ParentChildImplementation
#   attr_reader :parent
#   attr_reader :children

    include UpTreeAlgorithms
    include DownTreeAlgorithms

    # Create a new node and attach it to the parent
#   def initialize(parent)
#     @children = []
#     parent&.attach(self)
#   end

    def self.filter(*args) = DownTreeAlgorithms.filter(*args)
  end

# p Tree.ancestors
# exit

# module KeyedUpTreeAlgorithmsRoot
#   include KeyedUpTreeAlgorithms
#
#   def initialize
#     super
#     @pool = {}
#
# end

# class TreeAdapter < AbstractTree
#   attr_reader :parent_method
#   attr_reader :children_method
#   def parent = self.send(parent_method)
#   def children = self.send(children_method)
#
#   def initialize(root, parent_method, children_method)
#     @parent_method = parent_method
#     @children_method = children_method
#   end
# end
end

