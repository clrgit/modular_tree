
module Tree
  # A child node is not necessarily a tree, branches are

  module NodeProperty
    include Tracker
    abstract_module

    def node = abstract_method
  end

  module BranchProperty # Aka. 'parent'
    include Tracker
    abstract_module

    def branch = abstract_method
  end

  module BranchesProperty
    include Tracker
    abstract_module

    def branches = abstract_method
    def each_branch(&block) = branches.each(&block)
  end

  module ParentProperty
    include Tracker
    abstract_module

    def parent = abstract_method
  end

  module ChildrenProperty
    include Tracker
    abstract_module

    def children = abstract_method
    def each_child(&block) = children.each(&block)
  end

  module KeyProperty # Set
    include Tracker
    abstract_module

    def key = abstract_method
  end

  module KeysProperty # Map
    include Tracker
    abstract_module

    def keys = abstract_method
    def key?(k) = keys.include? k
    def [](key) = abstract_method
  end

  module RootProperty
    include Tracker
    require_module ParentProperty

    def root = @root ||= parent&.root
  end
end

