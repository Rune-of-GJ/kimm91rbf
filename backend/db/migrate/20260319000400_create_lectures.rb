class CreateLectures < ActiveRecord::Migration[8.1]
  def change
    create_table :lectures do |t|
      t.references :course, null: false, foreign_key: true
      t.string :title, null: false
      t.string :video_url, null: false
      t.integer :order_no, null: false
      t.integer :duration

      t.timestamps
    end

    add_index :lectures, [:course_id, :order_no], unique: true
  end
end
