RSpec.describe Auctions::Jobs::LosingBidderEmail do
  describe "#perform" do
    params = [
        "jonas@gat.com",
        "Sorry seems to be...",
        { highest_bid: 9001 }
      ]

    it "calls the API method of email delivery to send a single email" do
      expect(EmailDelivery::Api::Email).to receive(:deliver).with(*params)

      described_class.new.perform(*params)
    end
  end
end
