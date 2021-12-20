class CreateHeros < ActiveRecord::Migration[6.1]
  def change
    create_table :heros do |t|
      t.boolean :alive
      t.integer :health
      t.integer :strength
      t.integer :defense
      t.integer :experience
      t.integer :room_number
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end