
describe "Implementations" do
  def mk_klass(*modules)
    Class.new(Tree::AbstractTree) do
      include *modules.reverse
      attr_reader :key
      def initialize(parent, key)
        @key = key
        super(parent)
      end
      def to_s() = @key
    end
  end

  describe "ParentImplementation" do
    let(:tree) { mk_klass(Tree::InternalParentImplementation) }

    it "defines #parent" do
      r = tree.new(nil, "r")
      a = tree.new(r, "a")
      expect(r.parent).to eq nil
      expect(a.parent).to eq r
    end
  end

  describe "InternalChildrenArrayImplementation" do
    let(:tree) { mk_klass(Tree::InternalChildrenArrayImplementation) }

    it "defines #children" do
      r = tree.new(nil, "r")
      expect(r.children).to eq []
    end

    it "defines #attach" do
      r = tree.new(nil, "r")
      a = tree.new(nil, "a")
      r.attach(a)
      expect(r.children).to eq [a]
    end
  end

  describe "InternalChildrenListImplementation" do
    let(:tree) { mk_klass(Tree::InternalChildrenListImplementation) }

    it "defines #children" do
      r = tree.new(nil, "r")
      expect(r.children).to eq []
    end

    it "defines #attach" do
      r = tree.new(nil, "r")
      a = tree.new(nil, "a")
      r.attach(a)
      expect(r.children).to eq [a]
    end

    it "defines #first_child" do
      r = tree.new(nil, "r")
      a = tree.new(nil, "a")
      r.attach(a)
      expect(r.first_child).to eq a
      expect(a.first_child).to eq nil
    end
    
    it "defines #next_sibling" do
      a = tree.new(nil, "a")
      b = tree.new(nil, "b")
      c = tree.new(nil, "c")
      a.attach(b)
      a.attach(c)
      expect(a.next_sibling).to eq nil
      expect(b.next_sibling).to eq nil
      expect(c.next_sibling).to eq b
    end
  end

  describe "InternalParentChildImplementation" do
    let(:modules) { [
      Tree::InternalParentImplementation, 
      Tree::InternalChildrenArrayImplementation, 
      Tree::InternalParentChildImplementation,
    ] }

    let(:tree) { mk_klass(*modules) }

    it "links parent and child" do
      r = tree.new(nil, "r")
      a = tree.new(r, "a")
      expect(r.children).to eq [a]
      expect(a.parent).to eq r
    end

    it "redefine #attach" do
      r = tree.new(nil, "r")
      a = tree.new(nil, "a")
      r.attach(a)
      expect(r.children).to eq [a]
      expect(a.parent).to eq r
    end
  end
end

#     Tree::ParentImplementation,
#     Tree::InternalChildrenArrayImplementation #,
#     Tree::ParentChildImplementation #,
#     Tree::UpTreeAlgorithms,
#     Tree::DownTreeAlgorithms

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













