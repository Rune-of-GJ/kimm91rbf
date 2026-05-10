class CreateCoachingProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :coaching_products do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :tagline, null: false
      t.integer :price, null: false, default: 0
      t.integer :credits_amount, null: false, default: 1
      t.boolean :active, null: false, default: true
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :coaching_products, :slug, unique: true
    add_index :coaching_products, :active
  end
end
