require "rails_helper"

describe AlertMessage do
  let(:alert_message) { build(:alert_message) }

  describe "Concerns" do
    it_behaves_like "acts as paranoid", :alert_message
    it_behaves_like "globalizable", :alert_message
  end

  it "is valid" do
    expect(alert_message).to be_valid
  end

  it "assigns default values to new alert_messages" do
    alert_message = AlertMessage.new

    expect(alert_message.target_url).to be_present
    expect(alert_message.active).to be_present
    expect(alert_message.flash_key).to be_present
  end

  describe "scope" do
    describe ".with_active" do
      it "shows actives" do
        alert_message = create(:alert_message)

        expect(AlertMessage.with_active).to eq [alert_message]
      end
    end

    describe ".with_inactive" do
      it "shows inactives" do
        alert_message = create(:alert_message, active: false)

        expect(AlertMessage.with_inactive).to eq [alert_message]
      end
    end
  end
end
