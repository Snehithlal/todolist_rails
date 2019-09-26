class CreateTodolists < ActiveRecord::Migration[6.0]
  def change
    create_table :todolists do |t|
      t.string :body
      t.boolean :active, default: true

      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
