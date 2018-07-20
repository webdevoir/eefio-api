class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.string :name
      t.text :content
      t.string :data_type
      t.text :description

      t.timestamps
    end
  end
end
