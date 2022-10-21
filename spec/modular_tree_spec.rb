describe Tree do
  it 'has a version number' do
    expect(Tree::VERSION).not_to be_nil
  end

  it 'does something useful'
end

describe "Tree::PoolTree" do
  let(:klass) {
    Class.new do
      include Tree::NodePool
      include Tree::NodePath
      include Tree::ParentImplementation
      def self.pool = @pool
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
    it "initializes the pool" do
      expect(klass.pool).to eq({})
    end
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












