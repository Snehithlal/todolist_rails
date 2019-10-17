class CreateShares < ActiveRecord::Migration[6.0]
  def change
    create_table :shares do |t|
      t.references :todo, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean  :is_owner, default: false
      t.bigint :priority, default: 0

      t.timestamps
    end
  end
end
