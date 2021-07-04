RSpec.describe Auctions::Jobs::NotifyLosingBidders do
  describe "#perform" do
    it "calls the API method that notifies the losing bidders with the auction id" do
      expect(Auctions::Api::Auction).to receive(:notify_losing_bidders).with(9)

      described_class.new.perform(9)
    end
  end
end
