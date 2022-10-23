
describe "Tree::Tracker" do
# class NodeParent
# end
#
# class NodeChildren
# end
#
# class UpTreeAlgoritms
# end
#
# class DownTreeAlgorithms
# end

# class Tree
#   
# end

  module N1
    extend Tree::Tracker
    abstract_module
  end

  module N2
    extend Tree::Tracker
    abstract_module
  end

  module N3
    extend Tree::Tracker
    abstract_module
  end

  module I1
    extend Tree::Tracker
    provide_module N1
  end

  module I2
    extend Tree::Tracker
    provide_module N2
  end  

  module I3
    extend Tree::Tracker
    provide_module N3
  end

  module IX
    extend Tree::Tracker
    provide_module N1, N2
    def f(arg) end
#   def initialize(parent)
#     puts "IX#initialize(parent)"
#     super()
#   end
  end

  module A1
    extend Tree::Tracker
    require_module N1
#   def initialize(parent)
#     puts "A1#initialize(parent)"
#     super()
#   end
  end

  module A2
    extend Tree::Tracker
    require_module N1, N2
  end

  module A3
    extend Tree::Tracker
    require_module A2
  end

  module A4
    extend Tree::Tracker
    require_module A1, N3
  end

  class B1
    extend Tree::Tracker
#   require_module A3
#   require_module IX
#   provide_module N3

    use_module A3, IX
  end

  class B2
    extend Tree::Tracker

    provide_module N3
    use_module A4, IX

  end

  describe "::required_modules" do
    it "returns a list of explicit required modules" do
#     puts B1.use_module
      exit
      expect(I1.required_modules).to eq []
      expect(I2.required_modules).to eq []
      expect(I3.required_modules).to eq []
      expect(A1.required_modules).to eq [N1]
      expect(A2.required_modules).to eq [N1, N2]
      expect(A3.required_modules).to eq [A2]
      expect(A4.required_modules).to eq [A1, N3]
#     expect(B1.required_modules).to eq [A3]
#     expect(B2.required_modules).to eq [A3, I3]
    end
  end

  describe "::recursively_required_modules" do
    it "returns a list of implicitly required modules" do
      expect(I1.recursively_required_modules).to eq []
      expect(I2.recursively_required_modules).to eq []
      expect(I3.recursively_required_modules).to eq []
      expect(A1.recursively_required_modules).to eq [N1]
      expect(A2.recursively_required_modules).to eq [N1, N2]
      expect(A3.recursively_required_modules).to eq [A2, N1, N2]
      expect(A4.recursively_required_modules).to eq [A1, N1, N3]
#     expect(B1.recursively_required_modules).to eq [A3, A2, N1, N2]
#     expect(B2.recursively_required_modules).to eq [A3, A2, N1, N2, I3]
    end
  end

  describe "::provided_modules" do
    it "returns a list of explicit provided modules" do
      expect(I1.provided_modules).to eq [N1]
      expect(I2.provided_modules).to eq [N2]
      expect(I3.provided_modules).to eq [N3]
      expect(A1.provided_modules).to eq []
      expect(A2.provided_modules).to eq []
      expect(A3.provided_modules).to eq []
      expect(A4.provided_modules).to eq []
#     expect(B1.provided_modules).to eq [N3]
#     expect(B2.provided_modules).to eq []
    end
  end

  describe "::recursively_provided_modules" do
    it "returns a list of implicitly provided modules" do
      expect(I1.recursively_provided_modules).to eq [N1]
      expect(I2.recursively_provided_modules).to eq [N2]
      expect(I3.recursively_provided_modules).to eq [N3]
      expect(A1.recursively_provided_modules).to eq []
      expect(A2.recursively_provided_modules).to eq []
      expect(A3.recursively_provided_modules).to eq []
      expect(A4.recursively_provided_modules).to eq []
#     expect(B1.recursively_provided_modules).to eq [N3]
#     expect(B2.recursively_provided_modules).to eq [N3]
    end
  end

  describe "::all_provided_modules" do
    it "returns a list of all modules (incl. self)" do
      expect(I1.all_provided_modules).to eq [I1, N1]
      expect(I2.all_provided_modules).to eq [I2, N2]
      expect(I3.all_provided_modules).to eq [I3, N3]
      expect(A1.all_provided_modules).to eq [A1]
      expect(A2.all_provided_modules).to eq [A2]
      expect(A3.all_provided_modules).to eq [A3, A2]
      expect(A4.all_provided_modules).to eq [A4, A1]
#     expect(B1.all_provided_modules).to eq [B1, N3]
#     expect(B2.all_provided_modules).to eq [B2, N3]
    end
  end
end







