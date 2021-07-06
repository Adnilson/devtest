# Dependency injections between modules
container = Dry::Container.new
container.register(:find_user) { |id| Users::Api::User.get_by_id(id) }
container.register(:get_address) { |id| Users::Api::User.get_address(id) }

OrderDependencies = Dry::AutoInject(container)