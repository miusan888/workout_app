class CreateExercises < ActiveRecord::Migration[8.1]
  def change
    create_table :exercises do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.integer :duration
      t.date :exercised_on

      t.timestamps
    end
  end
end
