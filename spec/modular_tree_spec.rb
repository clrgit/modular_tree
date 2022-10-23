describe Tree do
  it 'has a version number' do
    expect(Tree::VERSION).not_to be_nil
  end

  it 'does something useful'
end


describe "Tree::PoolTree" do
#     include Tree::ParentImplementation
#     include Tree::ArrayImplementation
#     include Tree::ChildrenProperty
#     include Tree::PoolProperty
#     include Tree::KeyProperty
#     include Tree::ParentProperty
#     include Tree::UpTreeAlgorithms
#     include Tree::PathProperty


# let(:klass) {
#   Class.new do
#     include Tree::ParentProperty
#     include Tree::ChildrenProperty
#     include Tree::KeyProperty
#
#     include Tree::UpTreeAlgorithms # Ups: Overskriver ParentImplementation#parent
#     include Tree::DownTreeAlgorithms
#     include Tree::PathAlgorithms
#
#     include Tree::ParentImplementation
#     include Tree::ArrayImplementation
#
#     include Tree::Pool
#
#     attr_reader :key
#
#     def initialize(parent, key)
#       @key = key
#       parent&.attach(self)
#       self.send(:parent=, parent)
#       super()
#     end
#   end
# }


  let(:bare_tree) {
    Class.new(Tree::Tree)
  }

# describe "" do
#   it "asdfasdf" do
#     puts "==============================="
#     root = bare_tree.new(nil)
#     puts "==============================="
#     a = klass.new(root)
#     puts "==============================="
#     expect(a.parent).to eq root
#     expect(root.children).to eq [a]
#   end
# end

  let(:base) {
    Class.new(Tree::AbstractTree) do
      attr_reader :key
      def initialize(parent, key)
        p :BING
        @key = key
        super(parent)
      end
      def to_s() @key end
    end
  }

#     Tree::ParentImplementation,
#     Tree::ArrayImplementation #,
#     Tree::ParentChildImplementation #,
#     Tree::UpTreeAlgorithms,
#     Tree::DownTreeAlgorithms

  def mk_klass(*modules)
    Class.new(Tree::AbstractTree) do
      include Tree::Tracker
      use_module *modules
      attr_reader :key
      def initialize(parent, key)
        @key = key
        super(parent)
      end
      def to_s() = @key
    end
  end

  describe "ParentImplementation" do
    let(:tree) { mk_klass(Tree::ParentImplementation) }

    it "defines #parent" do
      r = tree.new(nil, "r")
      a = tree.new(r, "a")
      expect(r.parent).to eq nil
      expect(a.parent).to eq r
    end
  end

  describe "ArrayImplementation" do
    let(:tree) { mk_klass(Tree::ArrayImplementation) }

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

  describe "ParentChildImplementation" do
    let(:tree) { mk_klass(Tree::ParentChildImplementation, Tree::ArrayImplementation) }

    it "links up with parent" do
      r = tree.new(nil, "r")
      a = tree.new(r, "a")
      expect(r.children).to eq [a]
      expect(a.parent).to eq r
    end

    it "redefine ChildrenImplementation#attach" do
      r = tree.new(nil, "r")
      a = tree.new(nil, "a")
      r.attach(a)
      expect(r.children).to eq [a]
      expect(a.parent).to eq r
    end
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












