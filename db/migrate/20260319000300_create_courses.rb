class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.references :category, null: false, foreign_key: true
      t.string :instructor_name, null: false
      t.string :thumbnail_url
      t.references :instructor, foreign_key: { to_table: :users }
      t.date :start_date
      t.date :end_date
      t.date :enrollment_deadline
      t.integer :max_access_days

      t.timestamps
    end
  end
end
