class CreateTodos < ActiveRecord::Migration[6.0]
  def change
    create_table :todos do |t|
      t.string :body
      t.boolean :active, default: true

      t.bigint :priority
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
