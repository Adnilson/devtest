RSpec.describe Users::Api::User do
  describe ".get_by_id" do
    context "when user exists" do
      it "fetches the user" do
        created_user = Users::Models::User.create!(email: "mrbean@hydepark.com")

        result = described_class.get_by_id(created_user.id)

        expect(result).to be_success
        expect(result.value!.to_h).to eq(created_user.attributes.symbolize_keys.except(:created_at, :updated_at))
      end
    end

    context "when user does not exist" do
      it "returns a failure with user not found" do
        result = described_class.get_by_id(5)

        expect(result).to be_failure
        expect(result.failure).to eq({ code: :user_not_found })
      end
    end
  end

  describe ".create_address" do
    context "when the right params are passed" do
      it "creates the address" do
        user = Users::Models::User.create(email: "django@jazz.fr")
        address_params = Users::Api::DTO::AddressParams.new(
          street: "Stepney Alley 2",
          zip_code: "E1, E14",
          city: "London",
          user_id: user.id
        )

        result = described_class.create_address(address_params)

        expect(result).to be_success
        expect(result.value!.to_h).to match(
          address_params.to_h.merge(
            id: kind_of(String)
          )
        )
      end

      context "when user already has an address" do
        it "returns a failure" do
          user = Users::Models::User.create(email: "django@jazz.fr")
          user.create_address(street: "A", zip_code: "B", city: "C")
          address_params = Users::Api::DTO::AddressParams.new(
            street: "Stepney Alley 2",
            zip_code: "E1, E14",
            city: "London",
            user_id: user.id
          )

          result = described_class.create_address(address_params)

          expect(result).to be_failure
          expect(result.failure).to eq(
            code: :address_already_created
          )
        end
      end
    end

    context "when user does not exist" do
      it "returns a failure" do
        address_params = Users::Api::DTO::AddressParams.new(
          street: "Stepney Alley 2",
          zip_code: "E1, E14",
          city: "London",
          user_id: "f458b10c-99e1-42ec-abda-77d0b9917936"
        )

        result = described_class.create_address(address_params)

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :user_not_found
        )
      end
    end
  end

  describe ".get_address" do
    context "when user exists" do
      it "gets the address" do
        user = Users::Models::User.create(email: "django@jazz.fr")
        address_params = {
          street: "Stepney Alley 2",
          zip_code: "E1, E14",
          city: "London"
        }
        user.create_address(address_params)

        result = described_class.get_address(user.id)

        expect(result).to be_success
        expect(result.value!).to eq("Stepney Alley 2, E1, E14, London")
      end

      context "when the address does not exist" do
        it "returns a failure" do
          user = Users::Models::User.create(email: "django@jazz.fr")

          result = described_class.get_address(user.id)

          expect(result).to be_failure
          expect(result.failure).to eq(
            code: :address_not_found
          )
        end
      end
    end

    context "when user does not exist" do
      it "returns a failure" do
        user_id = "620192c0-9eee-4821-bd9b-bbde3094d26c"

        result = described_class.get_address(user_id)

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :user_not_found
        )
      end
    end
  end
end
