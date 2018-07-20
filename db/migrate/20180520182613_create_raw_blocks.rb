class CreateRawBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :raw_blocks do |t|
      t.integer :block_number
      t.text :content

      t.timestamps
    end
  end
end
