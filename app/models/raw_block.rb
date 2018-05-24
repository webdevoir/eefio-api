class RawBlock < ApplicationRecord
  validates :block_number, presence: true, uniqueness: true
end
