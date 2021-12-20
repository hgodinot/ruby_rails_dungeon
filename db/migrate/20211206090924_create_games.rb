class CreateGames < ActiveRecord::Migration[6.1]
  def change
    create_table :games do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :over
      t.boolean :start
      t.string :choice

      t.timestamps
    end
  end
end