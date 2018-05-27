# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_05_27_010105) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blocks", force: :cascade do |t|
    t.text "address"
    t.bigint "block_number"
    t.string "block_number_in_hex"
    t.bigint "difficulty"
    t.string "difficulty_in_hex"
    t.text "extra_data"
    t.bigint "gas_limit"
    t.string "gas_limit_in_hex"
    t.bigint "gas_used"
    t.string "gas_used_in_hex"
    t.text "logs_bloom"
    t.text "miner_address"
    t.text "mix_hash"
    t.bigint "nonce"
    t.string "nonce_in_hex"
    t.text "parent_block_address"
    t.datetime "published_at"
    t.string "published_at_in_hex"
    t.text "receipts_root"
    t.text "sha3_uncles"
    t.bigint "size_in_bytes"
    t.string "size_in_hex"
    t.text "state_root"
    t.bigint "total_difficulty"
    t.string "total_difficulty_in_hex"
    t.text "transactions_root"
    t.string "uncles"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "raw_blocks", force: :cascade do |t|
    t.integer "block_number"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["block_number"], name: "index_raw_blocks_on_block_number"
  end

  create_table "settings", force: :cascade do |t|
    t.string "name"
    t.text "content"
    t.string "data_type"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
