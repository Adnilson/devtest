# Dependency injections between modules
container = Dry::Container.new
container.register(:fetch_user) { |id| Users::Api::User.get_by_id(id) }
container.register(:get_address) { |id| Users::Api::User.get_address(id) }
container.register(:send_email) { |params| EmailDelivery::Api::Email.deliver(*params) }
container.register(:fetch_joke) { Requests::Joke::Request.new }

OrderDependencies = Dry::AutoInject(container)
