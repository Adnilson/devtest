class CreateAddressesAndAddShippingAddressToOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :addresses, id: :string do |t|
      t.references :user, type: :string
      t.string :city
      t.string :zip_code
      t.string :street

      t.timestamps
    end

    add_column :orders, :shipping_address, :string
  end
end
