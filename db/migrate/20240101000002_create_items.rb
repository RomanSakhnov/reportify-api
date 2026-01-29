class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.text :description
      t.string :category
      t.decimal :price, precision: 10, scale: 2
      t.integer :quantity, default: 0
      t.boolean :active, default: true, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :items, :category
    add_index :items, :active
  end
end
