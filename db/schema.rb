# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 1) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "auctions", id: :string, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "status"
    t.float "package_weight"
    t.float "package_size_x"
    t.float "package_size_y"
    t.float "package_size_z"
    t.string "creator_id", null: false
    t.string "winner_id"
    t.datetime "finishes_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_auctions_on_creator_id"
    t.index ["winner_id"], name: "index_auctions_on_winner_id"
  end

  create_table "bids", id: :string, force: :cascade do |t|
    t.string "bidder_id"
    t.string "auction_id"
    t.float "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["auction_id"], name: "index_bids_on_auction_id"
    t.index ["bidder_id"], name: "index_bids_on_bidder_id"
  end

  create_table "orders", id: :string, force: :cascade do |t|
    t.string "reference_number"
    t.string "auction_id"
    t.string "buyer_id"
    t.float "total_payment"
    t.string "shipping_method"
    t.string "payment_method"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "shipping_costs", default: 0.0
    t.index ["auction_id"], name: "index_orders_on_auction_id"
    t.index ["buyer_id"], name: "index_orders_on_buyer_id"
  end

  create_table "users", id: :string, force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
