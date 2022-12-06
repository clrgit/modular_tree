module Tree

  class Matcher
    def match(node)
      case expr
        when Proc
          expr.call(node)
        when Symbol
          node.respond_to?(expr) && node.send(expr)
        when Class
          node.is_a? expr
        when Array
          expr.any? { |klass| node.is_a? klass }
        when true, false
          expr
      else
        raise ArgumentError
      end
    end

    def initialize(expr)
      constrain expr, Proc, Symbol, Class, [Class], true, false
      @expr = expr
    end
  end

  class Filter
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
    #
    #   when +traverse+ is
    #     true    Traverse always. This is the default
    #     false   Traverse only if select didn't match
    #     nil     Expects +select+ to return a two-tuple of booleans. Can't be
    #             used when +select+ is true. TODO: Explain
    #
    # If the expression is a Proc object, it will be called with the current
    # node as argument. If the return value is true, the node is
    # selected/traversed and skipped otherwise. If the expression is a method
    # name (Symbol), the method will be called on each node with no arguments.
    # It is not an error if the method doesn't exists on the a given node but
    # the node is not selected/traversed
    #
    # If the expression is a class or an array of classes, a given node matches
    # if it is an instance of one of the classes or any subclass
    #
    # Filters should not have side-effects because they can be used in
    # enumerators that doesn't execute the filter unless the enumerator is
    # evaluated
    #
    # TODO: block argument
    #
    def initialize(select_expr = true, traverse_expr = true, &block)
      constrain select_expr, Proc, Symbol, Class, [Class], true
      constrain traverse_expr, Proc, Symbol, Class, [Class], true, false, nil
      select = mk_lambda(select_expr)
      traverse = mk_lambda(traverse_expr)
      @matcher = 
          case select
            when Proc
              case traverse
                when Proc; lambda { |node| [select.call(node), traverse.call(node)] }
                when true; lambda { |node| [select.call(node), true] }
                when false; lambda { |node| r = select.call(node); [r, !r] }
                when nil; lambda { |node| select.call(node) }
              end
            when true
              case traverse
                when Proc; lambda { |node| [true, traverse.call(node)] }
                when true; lambda { |_| [true, true] }
                when false; lambda { |_| [true, false] } # effectively same as #children.each
                when nil; raise ArgumentError
              end
          end
    end

    # Match +node+ against the filter and return a [select, traverse] tuple of booleans
    def match(node) = @matcher.call(node)

    # Combine two filters using 'or'
#   def ||(other)
#     constrain other, Filter
#     Filter.new
#   end

    # Create a proc if arg is a Symbol or an Array of classes. Pass through
    # Proc objects, true, false, and nil
    def mk_lambda(arg) = self.class.mk_lambda(arg)
    def self.mk_lambda(arg)
      case arg
        when Proc, true, false, nil
          arg
        when Symbol
          lambda { |node| node.respond_to?(arg) && node.send(arg) }
        when Class
          lambda { |node| node.is_a? arg }
        when Array
          arg.all? { |a| a.is_a? Class } or raise ArgumentError, "Array elements should be classes"
          lambda { |node| arg.any? { |a| node.is_a? a } }
      else
        raise ArgumentError
      end
    end

    ALL = Filter.new
  end
end

