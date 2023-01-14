module Tree
  # A pool assumes objects has a unique identifier
  #
  # Pool adds a @pool class variable to the including class and all of its
  # subclasses
  #
  # TODO: Make a separate gem. Then extend with with a lookup method and
  # optionally an specialized #dot method
  #
  module Pool
#   include PathAlgorithms

    def self.included(other)
      other.extend(ClassMethods)
      other.instance_variable_set(:@pool, {})
      super
    end

    def initialize(*args)
      super
      !self.class.uid?(self.uid) or raise TreeError, "Duplicate UID: #{self.uid}"
      self.class.send(:[]=, self.uid, self)
    end

    module ClassMethods
      def uid?(uid) = @pool.key?(uid)
      def uids = @pool.keys
      def nodes = @pool.values
      def size = @pool.size
      def empty? = @pool.empty?
      def empty! = @pool = {} # Useful in tests where a tree is created multiple times
      def [](uid) = @pool[uid]
      def []=(uid, node) @pool[uid] = node end

      def inherited(subclass)
        subclass.instance_variable_set(:@pool, @pool)
        super
      end
    end
  end
end

