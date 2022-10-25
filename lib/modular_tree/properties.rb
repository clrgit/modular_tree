
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
  end

  module BranchProperty # Aka. 'parent'
    def branch = abstract_method
  end

  module BranchesProperty
    def branches = abstract_method
    def each_branch(&block) = branches.each(&block)
  end

  module ParentProperty
    def parent = abstract_method
    def parent=() abstract_method end
  end

  module ChildrenProperty
    def children = abstract_method
    def each_child(&block) = children.each(&block)
    def attach(child) = abstract_method
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

