
module Tree
  # A child node is not necessarily a tree, branches are, but they have to use
  # #node to get the data
  #
  # Internal trees have child == branch

  module Property
    def initialize(_arg) end
  end

  module NodeProperty
    def node = abstract_method

    # FIXME: What is this. Also describe all properties in this file
    def node_value = abstract_method
  end

  module StemProperty # Aka. 'parent'
    def stem = abstract_method
  end

  module BranchesProperty
    def branches = abstract_method
    def bare? = branches.empty?
    def each_branch(&block) = branches.each(&block)
  end

  module ParentProperty
    def parent = abstract_method
    def parent=(arg) abstract_method end
  end

  module ChildrenProperty
    def children = abstract_method
    def each_child(&block) = children.each(&block)
    def attach(child) = abstract_method

    # :call-seq:
    #   detach(key)
    #   detach(child)
    #
    def detach(arg) = abstract_method
  end

  # TODO
  module ParentChildProperty
  end

  module KeyProperty # Set
    def key = abstract_method
  end

  module KeysProperty # Map
    def keys = abstract_method
    def key?(k) = keys.include? k
    def [](key) = abstract_method
  end

  module RootProperty
    def root = abstract_method # @root ||= parent&.root
  end
end

