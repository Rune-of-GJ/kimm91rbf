class CreateSolidCableMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :solid_cable_messages, force: :cascade do |t|
      t.text :channel, null: false
      t.text :payload, null: false
      t.datetime :created_at, null: false
    end

    add_index :solid_cable_messages, :channel
    add_index :solid_cable_messages, :created_at
  end
end
