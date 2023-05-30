class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.references :user_game, foreign_key: { on_delete: :cascade }
      t.references :country, foreign_key: true

      t.timestamps
    end
  end
end
