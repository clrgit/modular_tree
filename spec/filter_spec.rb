
describe "Tree::Filter" do
  class SomeNode < Tree::Tree
    def yes? = true
    def no? = false
  end

  context "when given a method name" do
    let(:node) { SomeNode.new(nil) }

    it "matches if the method exists and returns true" do
      filter = Tree::Filter.new(:yes?, true)
      select, traverse = filter.match(node)
      expect(select).to eq true
    end
    it "doesn't match if the method returns false" do
      filter = Tree::Filter.new(:no?, true)
      select, traverse = filter.match(node)
      expect(select).to eq false
    end
    it "doesn't match if the method doesn't exist" do
      filter = Tree::Filter.new(:not_there, true)
      select, traverse = filter.match(node)
      expect(select).to eq false
    end
  end
end


