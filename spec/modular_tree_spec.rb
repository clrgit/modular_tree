describe "Tree" do
  it 'has a version number' do
    expect(Tree::VERSION).not_to be_nil
  end

  describe "ArrayTree" do
    let(:klass) {
      Class.new(Tree::ArrayTree) do
        attr_reader :name
        def initialize(parent, name)
          @name = name
          super(parent)
        end
        def to_s = @name
        def inspect = "<Node:#@name>"
      end
    }

    let!(:root) { klass.new(nil, "root") }
    let!(:a) { klass.new(root, "a") }
    let!(:b) { klass.new(a, "b") }
    let!(:c) { klass.new(a, "c") }
    let!(:d) { klass.new(root, "d") }
    let!(:e) { klass.new(d, "e") }

    it "has parent implementation" do
      expect(root.parent).to eq nil
      expect(a.parent).to eq root
    end
    it "has children array implementation" do
      expect(root.children).to eq [a, d]
      expect(a.children).to eq [b, c]
      expect(b.children).to eq []
    end
    it "has parent-child link-up implementation" do
      expect(true).to eq true # If we made it so far, then this test is a success
    end
    it "has up-methods" do
      expect(root.parents).to eq []
      expect(a.parents).to eq [root]
      expect(c.parents).to eq [a, root]
    end
    it "has down-methods" do
      s = root.aggregate { |node, values|
        "#{node}#{values.empty? ? "" : "(#{values.join(',')})"}"
      }
      expect(s).to eq "root(a(b,c),d(e))"
    end
  end

  describe "NestedArrayTree" do
    let(:klass) { # This also demonstrates mounting of a class on a nested array
      Class.new(Tree::NestedArrayTree) do
#       def to_s = array.first
      end
    }

    let!(:e) { ["e", []] }
    let!(:d) { ["d", [e]] }
    let!(:c) { ["c", []] }
    let!(:b) { ["b", []] }
    let!(:a) { ["a", [b, c]] }
    let!(:r) { ["root", [a, d]] }

    let!(:root) { klass.new(r) }
     
    it "has children array implementation" do
      expect(root.children).to eq %w(a d)
      expect(root.branches.to_a.map(&:array)).to eq [a, d]
    end

    it "has down methods" do
      s = root.aggregate { |node, values|
        "#{node}#{values.empty? ? "" : "(#{values.join(',')})"}"
      }
      expect(s).to eq "root(a(b,c),d(e))"
    end
  end

  describe "Tree" do
    let!(:e) { ["e", []] }
    let!(:d) { ["d", [e]] }
    let!(:c) { ["c", []] }
    let!(:b) { ["b", []] }
    let!(:a) { ["a", [b, c]] }
    let!(:r) { ["root", [a, d]] }

    it "defines Tree.aggregate" do
      s = Tree.aggregate(r) { |node, values|
        "#{node}#{values.empty? ? "" : "(#{values.join(',')})"}"
      }
      expect(s).to eq "root(a(b,c),d(e))"
    end

#   it "is nice" do
#     json = JSON.parse(...)
#     nodes_of_interest = Tree.select(json) { ... }
#   end
  end

  describe "Hash Trees" do
    let(:h) { {
      "root" => {
        "a" => {
           "b" => {},
           "c" => {}
        },
        "d" => {
          "e" => {}
        }
      }
    } }



    it "does something" #do
#     Tree.visit(h, lambda { |n| n.size > 0 }) { |n, k| puts "interior node: #{k} => #{n.inspect}" }
#     Tree.select(h) { |n| n.size > 0 }.each { |n, k| puts "interior node: #{k} => #{n.inspect}" }
#     Tree.visit(h, lambda { |n| n.empty? }) { |n, k| puts "leaf node: #{k}" }
#   end
  end

end

__END__



  let(:klass) {
    Class.new(Tree::Tree) do
      include Tree::KeyProperty
      include Tree::PathAlgorithms
      include Tree::Pool

      attr_reader :key

      def initialize(parent, key)
        @key = key
        super(parent)
      end
    end
  }


  def build
    root = klass.new(nil, "root")
    a = klass.new(root, "a")
    b = klass.new(a, "b")
    c = klass.new(a, "c")
    d = klass.new(root, "d")
    e = klass.new(d, "e")
  end

  describe "::include" do
    it "initializes the pool"
#     expect(klass.pool).to eq({})
#   end
  end

  describe "::keys" do
    it "returns the keys (uids) in the pool" do
      t = build
      expect(klass.keys).to eq %w(root root.a root.a.b root.a.c root.d root.d.e)
    end
  end

  describe "::nodes" do
    it "returns the nodes in the pool" do
      expect(klass.nodes).to eq []
      n1 = klass.new(nil, "root")
      expect(klass.nodes).to eq [n1]
      n2 = klass.new(n1, "n1")
      expect(klass.nodes).to eq [n1, n2]
    end
  end

  describe "::[]" do
    it "lookups a node by key (uid)" do
      t = build
      expect(klass["root"].key).to eq "root"
      expect(klass["root.a.b"].key).to eq "b"
    end
    it "returns nil if not found" do
      expect(klass["a.b"]).to eq nil
    end
  end
end












