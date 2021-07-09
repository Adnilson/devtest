# Dependency injections between modules
container = Dry::Container.new
container.register(:create_order) { |params| Orders::Api::Order.create(params) }
container.register(:fetch_emails) { |ids| Users::Api::User.get_emails(ids) }
container.register(:send_email) { |params| EmailDelivery::Api::Email.deliver(*params) }

AuctionDependencies = Dry::AutoInject(container)
