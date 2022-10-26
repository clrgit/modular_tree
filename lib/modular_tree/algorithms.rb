
module Tree

  # A down tree can only be traversed bottom-up
  #
  # TODO: Add FilteredUpTreeAlgorithms
  #
  module UpTreeAlgorithms
    include NodeProperty
    include BranchProperty

    # Bottom-up
    def ancestors
      curr = self
      a = []
      a.push curr.node while curr = curr.branch
      a
    end

    # Top-down 
    def ancestry
      curr = self
      a = []
      a.unshift curr.node while curr = curr.branch
      a
    end

    def depth = @depth ||= ancestors.size
  end

  # A down tree can only be traversed top-down as it has no reference to its
  # parent. It is also a kind of a graph node
  #
  # TODO: Turn into class methods to implement array/hash/other adaptors.
  #       #children should then be called as 'children(node)' everywhere
  #
  #       A #node method should also be defined at the top-most level
  #
  # TODO: Better split between DownTreeAlgorithms and DownTreeFilteredAlgorithms
  #
  module DownTreeFilteredAlgorithms
    include NodeProperty
    include BranchesProperty

    # True if the node doesn't contain any branches
    def empty? = branches.empty?

    # The number of nodes in the tree. Note that this can be an expensive
    # operation since every node that to be visited
    def size = 1 + descendants.to_a.size

    # Enumerator of descendant nodes matching filter. Same as #preorder with
    # :this set to false
    def descendants(*filter) = preorder(filter, this: false)

    # Implementation of Enumerable#each
    def each(&block) = block_given? ? visit(&block) : preorder

    # Implementation of Enumerable#map
    def map(&block) = preorder.map(&block)

    # Nomenclature
    #   parent, branches, this # Does not necessarily contain tree-information
    #   branch, branches, node # Contains tree information
    #
    #   #this # Returns node without tree-information
    #   #node # Returns node with tree-information
    #
    #   #self -> acts as if it is a container of branches
    #   #each(&block) -> iterate all descendant branches
    #   #each_child(&block) -> iterate immediate branches
    #
    #   #nodes -> a container of nodes
    #   #each_node(&block) -> iterate all descendant nodes
    #   #each_branch(&block) -> iterate immediate branches

    # Like #each but with filters
    def filter(*filter, this: true, &block) 
      filter = self.class.filter(*filter)
      if block_given?
        do_filter(nil, filter, this, &block)
      else
        Enumerator.new { |enum| do_filter(enum, filter, this) }
      end
    end

    # Enumerator of nodes in the tree matching the filter. Aka. 'filter'
    alias_method :nodes, :filter

    # Pre-order enumerator of selected nodes
    def preorder(*filter, this: true)
      filter = self.class.filter(*filter)
      Enumerator.new { |enum| do_preorder(enum, filter, this) }
    end

    # Post-order enumerator of selected nodes
    def postorder(*filter, this: true) = raise NotImplementedError

    # Implementation of Enumerable#inject method
    def inject(default = nil, &block) = preorder.inject(default, &block)

#   def traverse(&block)
#     before()
#     yield(&block)
#     after()
#   end

    # Enumerator of edges in the tree. Edges are [previous-matching-node,
    # matching-node] tuples
    #
    def edges(*filter, this: true, &block)
      filter = self.class.filter(*filter)
      if block_given?
        do_edges(nil, filter, this, &block)
      else
        Pairs.new { |enum| do_edges(enum, filter, this) }
      end
    end

    # Return edges as from-node/to-node pairs where the from-node is selected
    # by the filter and the to-node is a descendant of the first node that
    # satisfies the given condition. The second node doesn't have to be matched
    # by the filter
    #
    # FIXME: Edges without a filter should do the expected
    def pairs(*filter, cond_expr, this: true, &block)
      filter = self.class.filter(*filter)
      cond = Filter.mk_lambda(cond_expr)
      if block_given?
        do_pairs(nil, filter, this, cond, &block)
      else
        Pairs.new { |enum| do_pairs(enum, filter, this, cond) }
      end
    end

    # Execute block on selected nodes. Effectively the same as
    # 'preorder(...).each(&block)' but faster as it doesn't create an
    # Enumerator
    def visit(*filter, this: true, &block)
      filter = self.class.filter(*filter)
      block_given? or raise ArgumentError, "Block is required"
      do_visit(filter, this, &block)
    end

    # Traverse the tree top-down while accumulating information in an
    # accumulator object. The block takes a [accumulator, node] tuple and is
    # responsible for adding itself to the accumulator. The return value from
    # the block is then used as the accumulator for the branch nodes. Note that
    # it returns the original accumulator and not the final result - this makes
    # it different from #inject
    def accumulate(*filter, accumulator, this: true, &block)
      filter = self.class.filter(*filter)
      block_given? or raise ArgumentError, "Block is required"
      do_accumulate(filter, this, accumulator, &block)
      accumulator
    end

    # Traverse the tree bottom-up while aggregating information. The block is
    # called with a [current-node, branch-node-results] tuple
    def aggregate(*filter, this: true, &block)
      filter = self.class.filter(*filter)
      do_aggregate(filter, this, &block)
    end

    # Find first node that matches the filter and that returns truthy from the block
    def find(*filter, &block) = descendants(*filter).first(&block)

    # Create a Tree::Filter object. Can also take an existing filter as
    # argument in which case the given filter will just be passed through
    def self.filter(*args)
      if args.first.is_a?(Filter)
        args.size == 1 or raise ArgumentError
        args.first
      else
        Filter.new(*args) 
      end
    end

  protected
    def do_preorder(enum, filter, this)
      select, traverse = filter.match(self)
      enum << self if this && select
      each_branch { |branch| branch.do_preorder(enum, filter, true) } if traverse || !this
    end

    # +enum+ is unused (and unchecked) if a block is given
    def do_edges(enum, filter, this, last_match = nil, &block)
      select, traverse = filter.match(node)
      if this && select
        if block_given?
          yield(last_match, node)
        else
          enum << [last_match, node]
        end
        last_match = node
      end
      each_branch { |branch| branch.do_edges(enum, filter, true, last_match, &block) } if traverse || !this
    end

    def do_pairs(enum, filter, this, cond, last_selected = nil, &block)
      select, traverse = filter.match(self)
      last_selected = self if this && select
      branches.each { |branch| 
        if last_selected && cond.call(branch)
          if block_given?
            yield(last_selected, branch)
          else
            enum << [last_selected, branch]
          end
        else
          branch.do_pairs(enum, filter, true, cond, last_selected, &block) 
        end
      } if traverse || !this
    end

    def do_filter(enum, filter, this, &block)
      select, traverse = filter.match(self)
      if this && select
        if block_given?
          yield self
        else
          enum << self
        end
      end
      branches.each { |branch| branch.do_filter(enum, filter, true, &block) } if traverse || !this
    end

    def do_visit(filter, this, &block)
      select, traverse = filter.match(self)
      yield(self) if this && select
      branches.each { |branch| branch.do_visit(filter, true, &block) } if traverse || !this
    end

    def do_accumulate(filter, this, acc, &block)
      select, traverse = filter.match(self)
      acc = yield(acc, self) if this && select
      branches.each { |branch| branch.do_accumulate(filter, true, acc, &block) } if traverse || !this
    end

    def do_aggregate(filter, this, &block)
      select, traverse = filter.match(self)
      values = traverse ? branches.map { |branch| branch.do_aggregate(filter, true, &block) } : []
#     values = traverse ? children.map { |child| child.do_aggregate(filter, true, &block) } : []
      yield(self, values)
    end
  end

  module DownTreeAlgorithms
    include DownTreeFilteredAlgorithms

#   def self.included(other)
#     other.include DownTreeFilteredAlgorithms
#     super
#   end

    def self.filter(*args) = DownTreeFilteredAlgorithms.filter(*args)

#   include DownTreeFilteredAlgorithms

    # Very lazy implementation
#   def descendants = preorder(Filter::ALL, this: false)
#   def filter(*args) = abstract_method
#   alias_method :nodes, :each
#   def edges(*args, **opts, &block) = super(Filter::ALL, *args, **opts, &block)
#   def pairs(*args, **opts, &block) = super(Filter::ALL, *args, **opts, &block)
#   def preorder(*args, **opts, &block) = super(Filter::ALL, *args, **opts, &block)
#   def postorder(*args, **opts, &block) = super(Filter::ALL, *args, **opts, &block)
#   def visit(*args, **opts, &block) = super(Filter::ALL, *args, **opts, &block)
#   def accumulate(*args, **opts, &block) = super(Filter::ALL, *args, **opts, &block)
#   def aggregate(*args, **opts, &block) = super(Filter::ALL, *args, **opts, &block)
#   def find(*args, **opts, &block) = super(Filter::ALL, *args, **opts, &block)
  end

  module PathAlgorithms
    include KeyProperty
    include UpTreeAlgorithms

    def separator = @separator ||= parent&.separator || ::Tree.separator
    def separator=(s) @separator = s end

    def path = @path ||= ancestry[1..-1]&.map(&:key)&.join(separator) || ""
    def uid() @uid ||= [parent&.uid, key].compact.join(separator) end
  end

  module DotAlgorithms
    include KeysProperty

    def dot(path) = Separator.split(path).keys.each.inject(self) { |a,e| a[e] }
  end
end

