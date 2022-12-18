
describe "Pool" do
  let(:klass) {
    Class.new(Tree::ArrayTree) do
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

  let(:subklass) {
    Class.new(klass) do
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

  describe "#initialize" do
    it "raises on duplicate keys" do
      expect { klass.new(nil, "x"); klass.new(nil, "x") }.to raise_error Tree::TreeError
    end
  end

  describe "::uid?" do
    it "returns true if the uid is present" do
      build
      expect(klass.uid? "root.a.b").to eq true
      expect(klass.uid? "root.a.d").to eq false

    end
  end

  describe "::uids" do
    it "returns the uids (uids) in the pool" do
      build
      expect(klass.uids).to eq %w(root root.a root.a.b root.a.c root.d root.d.e)
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

  describe "::size" do
    it "returns the number of objects in the pool" do
      expect(klass.size).to eq 0
      build
      expect(klass.size).to eq 6
    end
  end

  describe "::empty?" do
    it "returns true if the pool is empty" do
      expect(klass.empty?).to eq true
      build
      expect(klass.empty?).to eq false
    end
  end

  describe "::[]" do
    it "lookups a node by key (uid)" do
      build
      expect(klass["root"].key).to eq "root"
      expect(klass["root.a.b"].key).to eq "b"
    end
    it "returns nil if not found" do
      expect(klass["a.b"]).to eq nil
    end
  end

  describe "::[]=" do
    it "overwrites existing objects" do
      build
      klass["root.a.b"] = klass["root.a.c"]
      expect(klass["root.a.b"].uid).to eq "root.a.c"
      expect(klass["root.a.c"].uid).to eq "root.a.c"
    end
    it "adds new objects" do
      build
      klass["root.f"] = klass["root.a"]
      expect(klass["root.f"]).to eq klass["root.a"]
    end
  end

  context "with inherited classes" do
    it "subclasses enters the same pool as the parent" do
      expect {
        root = klass.new(nil, "root")
        a = subklass.new(root, "a")
      }.not_to raise_error
    end
  end
end







