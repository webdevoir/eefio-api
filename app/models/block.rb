class Block < ApplicationRecord
  validates :block_number,        presence: true, uniqueness: true
  validates :block_number_in_hex, presence: true, uniqueness: true
  validates :address,             presence: true, uniqueness: true
end
