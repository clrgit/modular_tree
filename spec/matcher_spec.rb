
describe "Matcher" do
  describe "Matcher" do
    let(:klass) {
      Class.new do
        attr_reader :value
        def initialize(value) = @value = value
        def is_even?() = !is_odd?
        def is_odd?() = (@value / 2) * 2 != @value
      end
    }

    let(:subklass) { Class.new(klass) do; end }
    let(:subsubklass) { Class.new(subklass) do; end }
    let(:a) { [klass.new(1), subklass.new(2), subsubklass.new(3)] }


    def match(arg = nil, &block) 
      matcher = arg.is_a?(Tree::AbstractMatcher) ? arg : Tree::Matcher.new(arg, &block)
      a.map { |e| matcher.match?(e) }
    end

    it "Matches nodes using a Proc object" do
      expect(match(lambda { |node| node.value >= 2 })).to eq [false, true, true]
      expect(match { |node| node.value >= 2 }).to eq [false, true, true]
    end
    it "Matches nodes using a method name" do
      expect(match(:is_even?)).to eq [false, true, false]
    end
    it "Matches nodes using a Class object" do
      expect(match(klass)).to eq [true, true, true]
      expect(match(subklass)).to eq [false, true, true]
      expect(match(subsubklass)).to eq [false, false, true]
    end
    it "Matches nodes using an array of classes" do
      expect(match([subklass, subsubklass])).to eq [false, true, true]
    end

    describe "#initialize" do
      def match(*args, &block)
        matcher = Tree::Matcher.new(*args, &block)
        a.map { |e| matcher.match?(e) }
      end

      it "accepts a Class" do
        expect(match(klass)).to eq [true, true, true]
      end

      it "accepts an array of Classes" do
        expect(match([subklass, subsubklass])).to eq [false, true, true]
      end

      it "accepts a list of Classes" do
        expect(match(subklass, subsubklass)).to eq [false, true, true]
      end
    end

    describe "#|" do
      it "Combines two matchers by the || operator" do
        left = Tree::Matcher.new { |node| node.value == 2 }
        right = Tree::Matcher.new { |node| node.value == 3 }
        matcher = left | right
        expect(match(matcher)).to eq [false, true, true]
      end
    end
    describe "#&" do
      it "Combines two matchers by the && operator" do
        left = Tree::Matcher.new { |node| [1, 2].include? node.value }
        right = Tree::Matcher.new { |node| [2, 3].include? node.value }
        matcher = left & right
        expect(match(matcher)).to eq [false, true, false]
      end
    end
    describe "#!" do
      it "Negates the result of the match" do
        matcher = !Tree::Matcher.new(subklass)
        expect(match(matcher)).to eq [true, false, false]
      end
    end
  end
end
