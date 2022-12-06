
describe "algorithms" do
  describe "DownTreeFilteredAlgorithms" do
    let(:klass) {
      Class.new(Tree::ArrayTree) do
        attr_reader :name
        attr_reader :value
        def initialize(parent, name, value)
          @name = name
          @value = value
          super(parent)
        end
        def even?() = @value.even? 
        def odd?() = @value.odd?
        def to_s = @name
        def inspect = "<Node:#@name>"
      end
    }

    let(:subklass) {
      Class.new(klass) do
      end
    }

    let!(:root) { klass.new(nil, "root", 0) }
    let!(:a) { klass.new(root, "a", 1) }
    let!(:b) { klass.new(a, "b", 2) }
    let!(:c) { subklass.new(a, "c", 3) }
    let!(:d) { subklass.new(root, "d", 4) }
    let!(:e) { klass.new(d, "e", 5) }

    describe "#each" do
    end

    describe "#select" do
      it "returns an array if given a block" do
        expect(root.select { false }).to be_a Array
      end
      it "returns an enumerator if not given a block" do
        expect(root.select(false)).to be_a Enumerator
      end
      it "selects all nodes satisfying the filter" do
        expect(root.select(subklass).to_a).to eq [c,d]
      end
      it "selects all nodes satisfying the block condition" do
        expect(root.select { |n| n.name == "e"}).to eq [e]
      end
    end

    describe "#nodes" do
      it "returns node objects" do
        expect(root.nodes(:even?, true).to_a).to eq [root, b, d]
      end
    end

    describe "#edges" do
      it "returns an enumerator of [first-match, second-match] nodes"

#       root.select(klass).map { |first|
#         first.each(subklass, false)
#       p klass
#       p subklass
#       root.each(klass, subklass) { |node, _, parent| p [parent.class, node.class] }
#       expect(root.edges(klass, subklass).to_a).to eq [[a, c], [root, d]]
#     end
    end

    describe "#pairs" do
      it "returns an array of [previous-match, current-match] objects" do
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

        matcher = Tree::Matcher.new(subklass) | Tree::Matcher.new { |node| node.name == "e" }

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
end










