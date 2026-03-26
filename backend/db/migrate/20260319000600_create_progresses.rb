class CreateProgresses < ActiveRecord::Migration[8.1]
  def change
    create_table :progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lecture, null: false, foreign_key: true
      t.boolean :watched, null: false, default: false
      t.datetime :watched_at

      t.timestamps
    end

    add_index :progresses, [:user_id, :lecture_id], unique: true
  end
end
