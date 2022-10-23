module Tree
  module ParentProperty
    include Tracker
    abstract_module

    def parent = abstract_method
  end

  module ChildrenProperty
    include Tracker
    abstract_module

    def children = abstract_method
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
