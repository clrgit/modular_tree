module Tree
  module Pool
    include Tracker
    require_module PathAlgorithms

    def self.included(other)
      other.extend(ClassMethods)
      other.instance_variable_set(:@pool, {})
      super
    end

    def initialize(_parent)
      super
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
end

