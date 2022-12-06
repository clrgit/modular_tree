module Tree
  class Filter
    # :call-seq:
    #   Filter.new(select_expr, traverse_expr)
    #   Filter.new(select_expr, &block)
    #   Filter.new(&block)
    #
    # Create a node filter. The filter is initialized by a select expression
    # and a traverse expression.  The select expression decides if the node
    # should be given to the block (or submitted to an enumerator) and the
    # traverse expression decides if the child nodes should be traversed
    # recursively
    #
    # The expressions can be a Proc, Symbol, Class, or an array of classes. In
    # addition, +select+ can be true, and +traverse+ can be true, false, or
    # nil. These values have special meanings:
    #
    #   when +select+ is
    #     true    Select always. This is the default
    #     false   This is an allowed value but it doesn't select any node
    #
    #   when +traverse+ is
    #     true    Traverse always. This is the default
    #     false   Traverse only if select didn't match
    #     nil     Expects +select+ to be a Proc object that returns a [select,
    #             traverse] tuple of booleans
    #
    # If the expression is a Proc object, it will be called with the current
    # node as argument. If the return value is true, the node is
    # selected/traversed and skipped otherwise. If the expression is a method
    # name (Symbol), the method will be called on each node with no arguments.
    # It is not an error if the method doesn't exists on the a given node but
    # the node is not selected/traversed. If the expression is a class or an
    # array of classes, a given node matches if it is an instance of one of the
    # classes or any subclass
    #
    # If a block is given, it is supposed to return a [select, traverse] tuple
    # of booleans
    #
    # Filters should not have side-effects because they can be used in
    # enumerators that doesn't execute the filter unless the enumerator is
    # evaluated
    #
    def initialize(select_expr = nil, traverse_expr = nil, &block)
      if select_expr.nil? && block_given?
        @matcher = block
      else
        select_expr ||= true
        traverse_expr ||= (block_given? ? block : true)
        select = Matcher.new(select_expr)
        traverse = Matcher.new(traverse_expr)
        @matcher = lambda { |node| [select.match(node), traverse.match(node)] }
      end
    end

    # Match +node+ against the filter and return a [select, traverse] tuple of booleans
    def match(node) = @matcher.call(node)

    ALL = Filter.new
  end
end

