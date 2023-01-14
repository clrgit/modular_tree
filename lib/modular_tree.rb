require 'abstract_method_error'

require "indented_io"

require 'constrain'
include Constrain

require 'forward_to'
include ForwardTo

module Tree
  class TreeError < RuntimeError; end
end

require_relative "modular_tree/version"
require_relative "modular_tree/separator"
require_relative "modular_tree/matcher"
require_relative "modular_tree/filter"
require_relative "modular_tree/pairs"

# Order is important here
require_relative "modular_tree/properties"
require_relative "modular_tree/implementations"
require_relative "modular_tree/algorithms"

# Should be after the above group
require_relative "modular_tree/pool"

module Tree
  DEFAULT_SEPARATOR = "."

  # TODO: Move to algorithms
  @separator = nil
  def Tree.separator = @separator ||= DEFAULT_SEPARATOR
  def Tree.separator=(s) @separator = s end

  class AbstractTree
    def empty? = abstract_method
    def size = abstract_method
  end

  # A regular tree
  #
  class ArrayTree < AbstractTree # Aka. SetTree aka. Tree
    include InternalParentImplementation
    include InternalChildrenArrayImplementation
    include InternalParentChildArrayImplementation
    include UpTreeAlgorithms
    include DownTreeAlgorithms
    include DownTreeFilteredAlgorithms

    def self.filter(*args) = DownTreeAlgorithms.filter(*args)
  end

  class FilteredArrayTree < ArrayTree
    include DownTreeFilteredAlgorithms

    def self.filter(*args) = FilteredDownTreeAlgorithms.filter(*args)
  end

  # TODO: Hide
  class NestedArrayTree < AbstractTree
    include ExternalChildrenArrayImplementation
    include DownTreeAlgorithms

    def initialize(array)
      super(nil)
      self.array = array
    end

    def self.filter(*args) = DownTreeAlgorithms.filter(*args)
  end

  # Module level algorithms on nested array trees
  #
  def self.aggregate(arg, *args, &block)
    case arg
      when Array; NestedArrayTree.new(arg).aggregate(*args, &block)
    else
      raise ArgumentError
    end
  end

  def self.aggregate(arg, *args, &block) = class_of(arg).new(arg).aggregate(*args, &block)

  # TODO: Hide
  def self.class_of(arg)
    constrain arg, Array
    if arg.size == 2 && arg.last.is_a?(Array)
      NestedArrayTree
    else
      raise "Oops"
    end
  end

# data = 
#   ["root", [
#     ["a", [
#       ["b", []],
#       ["c", []]
#     ]],
#     ["d", [
#       ["e", []],
#     ]]
#   ]]
#
# tree = NestedArrayTree.new(data)
# tree.visit { ... }
#
# tree.traverse { before(); yield; after() }
#
# NestedArrayTree.visit(data) { ... }
#
# NestedArrayTree.adapt(data)
# data.visit { ... }
#       

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

