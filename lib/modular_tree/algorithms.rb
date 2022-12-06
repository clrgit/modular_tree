
module Tree

  # A down tree can only be traversed bottom-up
  #
  # TODO: Add FilteredUpTreeAlgorithms
  #
  module UpTreeAlgorithms
    include NodeProperty
    include BranchesProperty

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

  # IDEA
  #
  #   tree.forrest -> Forrest
  #   tree.nodes -> Use node instead of value
  #   tree.forrest.nodes -> both


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

    # True if the node doesn't contain any branches (#empty? for trees)
    def bare? = raise NotImplemented

    # The number of nodes in the tree. Note that this can be an expensive
    # operation because every node has to be visited
    def size = 1 + descendants.to_a.size

    # Enumerator of descendant nodes matching filter. Same as #preorder with
    # :this set to false. TODO: Maybe introduce forrests: tree.forrest.each
    def descendants(*filter) = each(filter, this: false)

    # Implementation of Enumerable#each extended with filters. The block is
    # called with value, key, and parent as arguments (it may choose to
    # ignore key and/or parent). Returns an enumerator of values without a block
    def each(*filter, this: true, &block) = common_each(*filter, :value, :do_each_preorder, this, &block)

    # Implementation of Enumerable#select extended with a single filter. As
    # #each, the block is called with value, key, and parent arguments
    def select(filter = nil, this: true, &block)
      if block_given?
        each(block, true, this: this).to_a
      else
        each(filter || true, true, this: this)
      end
    end

    # Like #each but the block is called with node, key, and parent instead of
    # value, key, and parent
    def nodes(*filter, this: true, &block) = common_each(*filter, :node, :do_each_preorder, this, &block)

    # Pre-order enumerator of selected nodes. Same as #each without a block
    def preorder(*filter, this: true) = each(*filter, this: this)

    # Post-order enumerator of selected nodes
    def postorder(*filter, this: true) = common_each(*filter, :value, :each_postorder, this)

    # Enumerator of edges in the tree. Edges are [previous-matching-node,
    # matching-node] tuples. Top-level nodes have previous-matching-node set to
    # nil
    #
    # FIXME
    #
    # root
    #   match-first-a
    #     match-first-b
    #       match-second
    #
    # Should return
    #   [match-first-b, match-second] and not [match-first-a, match-second]
    #
    # ^or maybe this is how #pairs should work?
    #
    def edges(*filter, this: true, &block)
      if block_given?
        each(*filter, this: this) { |node, _, parent| yield parent, node }
      else
        Pairs.new { |enum| each(*filter, this: this) { |node, _, parent| enum << [parent, node] } }
      end
    end

    # Visit all nodes matching +filter+, stops further recursion if the block
    # returns false or nil
    def traverse(filter, this: true, &block)
      each(filter, false) {
        
      }
      
    end




    def do_pair


      
    end

    # 
    def pairs(first, second, this: true)
      
      

      stack = []
      visit(first) { |node|
        stack.push node
        node.visit
      }
      if block_given?
        
      else
      end
    end

#   def pairs(filter, filter, &block)
#   end

    # Traverse the tree top-down while accumulating information in an
    # accumulator object. The block takes a [accumulator, node] tuple and is
    # responsible for adding itself to the accumulator. The return value from
    # the block is then used as the accumulator for the branch nodes. Note that
    # it returns the original accumulator and not the final result - this makes
    # it different from #inject
    #
    # #accumulate is a kind of "preorder" algorithm
    def accumulate(*filter, accumulator, this: true, &block)
      filter = self.class.filter(*filter)
      block_given? or raise ArgumentError, "Block is required"
      do_accumulate(filter, this, accumulator, &block)
      accumulator
    end

    # Traverse the tree bottom-up while aggregating information. The block is
    # called with a [current-node, branch-node-results] tuple
    #
    # #aggregate is a kind of "postorder" algorithm
    #
    # TODO: Remove +this+ flag - it not used and doesn't make sense
    def aggregate(*filter, this: true, &block)
      filter = self.class.filter(*filter)
      do_aggregate(filter, this, &block)
    end

    # Stops further recursion if the block returns truthy
    def propagate(*filter, this: true, &block)
      
    end

    # tree.each(DocumentNode).select(BriefNode).each { |doc, brief| ... }
    # tree.edges(DocumentNode, BriefNode).group.all? { |doc, briefs| briefs.size <= 1 }
    # tree.map(DocumentNode) { |doc| doc.select(BriefNode).size <= 1 or raise }

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
    def common_each(*filter, value_method, each_method, this, &block)
      filter = self.class.filter(*filter)
      if block_given?
        self.send(each_method, nil, filter, value_method, nil, nil, this, &block)
      else
        Enumerator.new { |enum| self.send(each_method, enum, filter, value_method, nil, nil, this) }
      end
    end

    # TODO: Split into automatically generated variants
    def do_each_preorder(enum, filter, value_method, key, parent, this, &block)
      select, traverse = filter.match(self)
      if select && this
        value = self.send(value_method)
        if block_given?
          yield(value, key, parent)
        else
          enum << value
        end
        parent = value
      end
      if !this || traverse
        each_branch { |branch, key| 
          branch.do_each_preorder(enum, filter, value_method, key, parent, true, &block) 
        }
      end
    end

    def do_each_postorder(enum, filter, value_method, key, parent, this, &block)
      select, traverse = filter.match(self)
      if !this || traverse
        each_branch { |branch, key| 
          branch.do_each_postorder(enum, filter, value_method, key, p, true, &block) 
        }
      end
      if select && this
        value = self.send(value_method)
        if block_given?
          yield(value, key, parent)
        else
          enum << value
        end
      end
    end

    def do_traverse(filter, this, key, parent, &block)
      select, traverse = filter.match(self)
      if select && this
        return if yield(self, key, parent)
      end
      if !this || traverse
        each_branch { |branch, key| branch.do_propagate(filter, key, self.value) }
      end
    end

    def do_propagate(filter, this, key, parent, &block)
      select, traverse = filter.match(self)
      if select && this
        return if yield(self, key, parent)
      end
      if !this || traverse
        each_branch { |branch, key| branch.do_propagate(filter, key, self.value) }
      end
    end

    def do_accumulate(filter, this, acc, &block)
      select, traverse = filter.match(self)
      acc = yield(acc, self.value) if this && select
      each_branch.each { |branch| branch.do_accumulate(filter, true, acc, &block) } if traverse || !this
    end

    def do_aggregate(filter, this, &block) # TODO: use select-status
      block_given? or raise ArgumentError
      select, traverse = filter.match(self)
      values = traverse ? each_branch { |branch| 
        r = branch.do_aggregate(filter, true, &block) 
      }.to_a : []
      yield(self.value, values)
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

