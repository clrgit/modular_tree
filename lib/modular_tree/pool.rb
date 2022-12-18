module Tree
  # A pool assumes objects has a unique identifier
  #
  # Pool adds a @pool class variable to the including class and all of its
  # subclasses
  #
  module Pool
    include PathAlgorithms

    def self.included(other)
      other.extend(ClassMethods)
      other.instance_variable_set(:@pool, {})
      super
    end

    def initialize(*args)
      super
      self.class.send(:[]=, self.uid, self)
    end

    module ClassMethods
      def uid?(uid) = @pool.key?(uid)
      def uids = @pool.keys
      def nodes = @pool.values
      def size = @pool.size
      def empty? = @pool.empty?
      def [](uid) = @pool[uid]
      def []=(uid, node) @pool[uid] = node end

      def inherited(subclass)
        subclass.instance_variable_set(:@pool, @pool)
        super
      end
    end
  end
end

