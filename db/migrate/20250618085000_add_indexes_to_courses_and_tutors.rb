class AddIndexesToCoursesAndTutors < ActiveRecord::Migration[8.0]
  def change
    add_index :courses, :name, unique: true, if_not_exists: true
    add_index :tutors, :email, unique: true, if_not_exists: true
  end
end
