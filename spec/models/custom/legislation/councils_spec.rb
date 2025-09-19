require "rails_helper"

describe Legislation::Council do
  let(:council) { create(:legislation_council) }

  it_behaves_like "acts as paranoid", :legislation_council
  it_behaves_like "globalizable", :legislation_council

  describe "validations" do
    it "is valid" do
      expect(council).to be_valid
    end

    it "is not valid without a name" do
      council.name = nil
      expect(council).not_to be_valid
    end

    describe "translations" do
      it "is not valid without a translated name" do
        council.translations.first.name = nil
        expect(council).not_to be_valid
      end
    end
  end

  describe "associations" do
    it "has many processes" do
      process1 = create(:legislation_process)
      process2 = create(:legislation_process)
      
      council.processes << process1
      council.processes << process2

      expect(council.processes).to include(process1)
      expect(council.processes).to include(process2)
    end

    it "nullifies processes when destroyed" do
      process = create(:legislation_process)
      council.processes << process
      
      council.destroy

      process.reload
      expect(process.council_id).to be_nil
    end
  end

  describe "scopes" do
    let!(:active_council) { create(:legislation_council) }
    let!(:inactive_council) { create(:legislation_council, :inactive) }

    it "active returns only active councils" do
      expect(Legislation::Council.active).to include(active_council)
      expect(Legislation::Council.active).not_to include(inactive_council)
    end
  end

  describe "paranoia" do
    it "hides council using hidden_at" do
      council.destroy
      expect(council.hidden_at).to be_present
    end

    it "restores hidden council" do
      council.destroy
      council.restore
      expect(council.hidden_at).to be_nil
    end
  end
end
