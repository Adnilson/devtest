class AddShippingCostsToOrders < ActiveRecord::Migration[6.1]
  def up
    add_column :orders, :shipping_costs, :float, default: 0.0
  end

  def down
    remove_column :orders, :shipping_costs
  end
end
