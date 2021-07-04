RSpec.describe Orders::Jobs::NotifyOrderCreation do
  describe "#perform" do
    it "calls the API method that notifies the buyer" do
      expect(Orders::Api::Order).to receive(:notify_order_creation).with(9)

      described_class.new.perform(9)
    end
  end
end
