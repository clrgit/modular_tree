
describe "Tree::Tracker" do
  module N1
    include Tree::Tracker
    abstract_module
  end

  module N2
    include Tree::Tracker
    abstract_module
  end

  module N3
    include Tree::Tracker
    abstract_module
  end

  module I1
    include Tree::Tracker
    provide_module N1
  end

  module I2
    include Tree::Tracker
    provide_module N2
  end  

  module I3
    include Tree::Tracker
    provide_module N3
  end

  module IX
    include Tree::Tracker
    provide_module N1, N2
  end

  module A1
    include Tree::Tracker
    require_module N1
  end

  module A2
    include Tree::Tracker
    require_module N1, N2
  end

  module A3
    include Tree::Tracker
    require_module A2
  end

  module A4
    include Tree::Tracker
    require_module A1, N3
  end

  class B1
    include Tree::Tracker
    use_module A3, IX
  end

  class B2
    include Tree::Tracker
    provide_module N3
    use_module A4, IX
  end

  describe "::required_modules" do
    def rm(m) = m.send :required_modules
    it "returns a list of explicit required modules" do
      expect(rm I1).to eq []
      expect(rm I2).to eq []
      expect(rm I3).to eq []
      expect(rm A1).to eq [N1]
      expect(rm A2).to eq [N1, N2]
      expect(rm A3).to eq [A2]
      expect(rm A4).to eq [A1, N3]
    end
  end

  describe "::recursively_required_modules" do
    def rrm(m) = m.send :recursively_required_modules
    it "returns a list of implicitly required modules" do
      expect(rrm I1).to eq []
      expect(rrm I2).to eq []
      expect(rrm I3).to eq []
      expect(rrm A1).to eq [N1]
      expect(rrm A2).to eq [N1, N2]
      expect(rrm A3).to eq [A2, N1, N2]
      expect(rrm A4).to eq [A1, N1, N3]
    end
  end

  describe "::provided_modules" do
    def pm(m) = m.send :provided_modules
    it "returns a list of explicit provided modules" do
      expect(pm I1).to eq [N1]
      expect(pm I2).to eq [N2]
      expect(pm I3).to eq [N3]
      expect(pm A1).to eq []
      expect(pm A2).to eq []
      expect(pm A3).to eq []
      expect(pm A4).to eq []
    end
  end

  describe "::recursively_provided_modules" do
    def rpm(m) = m.send :recursively_provided_modules
    it "returns a list of implicitly provided modules" do
      expect(rpm I1).to eq [N1]
      expect(rpm I2).to eq [N2]
      expect(rpm I3).to eq [N3]
      expect(rpm A1).to eq []
      expect(rpm A2).to eq []
      expect(rpm A3).to eq []
      expect(rpm A4).to eq []
    end
  end

  describe "::all_provided_modules" do
    def apm(m) = m.send :all_provided_modules
    it "returns a list of all modules (incl.send : self)" do
      expect(apm I1).to eq [I1, N1]
      expect(apm I2).to eq [I2, N2]
      expect(apm I3).to eq [I3, N3]
      expect(apm A1).to eq [A1]
      expect(apm A2).to eq [A2]
      expect(apm A3).to eq [A3, A2]
      expect(apm A4).to eq [A4, A1]
    end
  end
end







