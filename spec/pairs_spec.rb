describe "Tree::Pairs" do
  describe "group" do
    def groups_to_s(a)
      a.map { |first, rest| "#{first || 'nil'}->#{rest.join(',')}" }.join " "
    end

    it "groups pairs on first element" do
      a = [
        ["root", "a"],
        ["a", "b"],
        ["a", "c"],
        ["root", "d"],
        ["d", "e"]
      ]

      groups = Tree::Pairs.new { |enum| a.each { |e| enum << [e.first, e.last] } }.group
      expect(groups_to_s groups).to eq "root->a,d a->b,c d->e"
    end
  end
end


