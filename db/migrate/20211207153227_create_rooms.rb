class CreateRooms < ActiveRecord::Migration[6.1]
  def change
    create_table :rooms do |t|
      t.string :encounter
      t.boolean :visited
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
