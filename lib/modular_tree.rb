require 'abstract_method_error'

require 'constrain'
include Constrain

require 'forward_to'
include ForwardTo

require_relative "modular_tree/dependencies"
require_relative "modular_tree/version"
require_relative "modular_tree/separator"
require_relative "modular_tree/filter"
require_relative "modular_tree/pairs"

# Order is important here
require_relative "modular_tree/properties"
require_relative "modular_tree/implementations"
require_relative "modular_tree/algorithms"

require_relative "modular_tree/pool"

require "indented_io"

module Tree
  DEFAULT_SEPARATOR = "."

  @separator = nil
  def Tree.separator = @separator ||= DEFAULT_SEPARATOR
  def Tree.separator=(s) @separator = s end
end

module Tree
  class AbstractTree
    def empty? = abstract_method
    def size = abstract_method
  end

  # A regular tree. Users of this library should derived their base class from Tree
  #
  class ArrayTree < AbstractTree # Aka. SetTree aka. Tree
    include Tracker

    use_module \
      Tree::ParentImplementation,
      Tree::ArrayImplementation #,
#     Tree::ParentChildImplementation #,
#     Tree::UpTreeAlgorithms,
#     Tree::DownTreeAlgorithms

    def self.filter(*args) = DownTreeAlgorithms.filter(*args)
  end

  Tree = ArrayTree

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

