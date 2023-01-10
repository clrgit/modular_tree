
describe "Algorithms" do
  let(:klass) {
    Class.new(Tree::ArrayTree) do
      include Tree::PathAlgorithms
      attr_reader :name
      def initialize(parent, name)
        @name = name
        super(parent)
      end
      def to_s = @name
      def inspect = "<Node:#@name>"
    end
  }

  let(:odd_even_klass) {
    Class.new(klass) do
      attr_reader :value
      def initialize(parent, name, value)
        super(parent, name)
        @value = value
      end
      def even?() = @value.even? 
      def odd?() = @value.odd?
    end
  }

  let(:odd_even_subklass) {
    Class.new(odd_even_klass) do
    end
  }

  describe "UpTreeAlgorithms" do
    let!(:root) { odd_even_klass.new(nil, "root", 0) }
    let!(:a) { odd_even_klass.new(root, "a", 1) }
    let!(:b) { odd_even_klass.new(a, "b", 2) }
    let!(:c) { odd_even_subklass.new(a, "c", 3) }
    let!(:d) { odd_even_subklass.new(root, "d", 4) }
    let!(:e) { odd_even_klass.new(d, "e", 5) }

    describe "parents" do
      it "returns a bottom-up list of parents" do
        expect(e.parents).to eq [d, root]
      end
      it "applies a filter if present" do
        expect(e.parents(:even?)).to eq [d, root]
        expect(e.parents(:even?, false)).to eq [d]
        expect(b.parents(:odd?)).to eq [a]
      end
    end

    describe "ancestors" do
      it "returns a top-down list of ancestors" do
        expect(e.ancestors).to eq [root, d]
      end
    end
  end

  describe "DownTreeFilteredAlgorithms" do
#   let(:klass) {
#     Class.new(Tree::ArrayTree) do
#       attr_reader :name
#       attr_reader :value
#       def initialize(parent, name, value)
#         @name = name
#         @value = value
#         super(parent)
#       end
#       def even?() = @value.even? 
#       def odd?() = @value.odd?
#       def to_s = @name
#       def inspect = "<Node:#@name>"
#     end
#   }
#
#   let(:subklass) {
#     Class.new(klass) do
#     end
#   }

    let!(:root) { odd_even_klass.new(nil, "root", 0) }
    let!(:a) { odd_even_klass.new(root, "a", 1) }
    let!(:b) { odd_even_klass.new(a, "b", 2) }
    let!(:c) { odd_even_subklass.new(a, "c", 3) }
    let!(:d) { odd_even_subklass.new(root, "d", 4) }
    let!(:e) { odd_even_klass.new(d, "e", 5) }

    describe "#bare?" do
      it "is true iff the node has no branches" do
        expect(root.bare?).to eq false
        expect(b.bare?).to eq true
      end
    end

    describe "#each" do
    end

    describe "#select" do
      it "returns an array if given a block" do
        expect(root.select { false }).to be_a Array
      end
      it "returns an array if given a filter" do
        expect(root.select(false)).to be_a Array
      end
      it "returns an enumerator if not given a block or a filter" do
        expect(root.select).to be_a Enumerator
      end
      it "selects all nodes satisfying the filter" do
        expect(root.select(odd_even_subklass).to_a).to eq [c,d]
      end
      it "selects all nodes satisfying the block condition" do
        expect(root.select { |n| n.name == "e"}).to eq [e]
      end
    end

    describe "#choose" do
      it "returns an array if given a block" do
        expect(root.choose { false }).to be_a Array
      end
      it "returns an arrya if given a filter" do
        expect(root.choose(false)).to be_a Array
      end
      it "returns an enumerator if not given a block or a filter" do
        expect(root.choose).to be_a Enumerator
      end
      it "chooses children satisfying the filter" do
        expect(root.choose(odd_even_subklass).to_a).to eq [d]
      end
      it "chooses children satisfying the block condition" do
        expect(root.choose { |n| n.is_a? odd_even_subklass }).to eq [d]
      end
    end

    describe "#nodes" do
      it "returns node objects" do
        expect(root.nodes(:even?, true).to_a).to eq [root, b, d]
      end
    end

    describe "#edges" do
      it "returns an enumerator of [previous-match, current-match] nodes" do
        expect(a.edges(true, true).to_a).to eq [[nil,a], [a,b], [a,c]]
      end
    end

    describe "#pairs" do
      it "returns an array of [previous-match, current-match] nodes" do
        expect(root.pairs(:even?, :odd?)).to eq [[root, a], [d, e]]
      end
    end

    describe "#traverse" do
      let!(:array_representation) {
        [
          [root,[ 
            [a,[
              [b,[]], 
              [c,[]] 
            ]], 
            [d, [
              [e,[]]
            ]] 
          ]]
        ]
      }

      it "allows pre- and post-iteration code" do
        before = []
        traversed = []
        collected = []
        after = []

        matcher = Tree::Matcher.new(odd_even_subklass) | Tree::Matcher.new { |node| node.name == "e" }

        traversed = root.traverse(matcher, false, this: true) { |node, inner|
          before << node
          result = [node, inner.call(node)] # Array representation
          after << node
          result
        }

        expect(before).to eq [c, d, e]
        expect(traversed).to eq [ [c,[]], [d,[[e, []]]] ]
        expect(after).to eq [c, e, d] # collects postorder
      end

      it "returns an array of the block values" do
        traversed = []
        matcher = Tree::Matcher.new(true)
        traversed = root.traverse(matcher, false, this: true) { |node, inner|
          [node, inner.call(node)]
        }
        expect(traversed).to eq array_representation
      end

      it "can define accumulate"
#     it "can define accumulate" do
#       acc = []
#       matcher = Tree::Matcher.new(true)
#       result = root.traverse(matcher, this: true) { |node, inner|
#         node.value + inner.call(node).sum
#       }
#       expect(result).to eq 15
#     end

      it "can define postorder" do
        postorder = []
        matcher = Tree::Matcher.new(true)
        root.traverse(matcher, false, this: true) { |node, inner| 
          inner.call(node)
          postorder << node
        }
        expect(postorder).to eq [b, c, a, e, d, root]
      end
    end
  end

  describe "PatchAlgorithms" do
    let(:klass) {
      Class.new(Tree::ArrayTree) do
        include Tree::PathAlgorithms
        attr_reader :name
        def initialize(parent, name)
          @name = name
          super(parent)
        end
      end
    }
    let!(:root) { klass.new(nil, "root") }
    let!(:a) { klass.new(root, "a") }
    let!(:b) { klass.new(a, "b") }
    let!(:c) { klass.new(a, "c") }
    let!(:d) { klass.new(root, "d") }
    let!(:e) { klass.new(d, "e") }
    
    describe "#search" do
      it "returns the first matching ancestor" do
        expect(e.search { |node| node.name == "d" }).to eq d
      end
      it "returns nil if not found" do
        expect(e.search { |node| node.name == "not" }).to eq nil
      end
    end
  end
end










