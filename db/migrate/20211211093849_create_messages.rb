class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.string :body
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
