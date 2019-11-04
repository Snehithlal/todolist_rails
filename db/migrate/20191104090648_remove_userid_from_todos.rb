class RemoveUseridFromTodos < ActiveRecord::Migration[6.0]
  def change
    remove_column :todos, :user_id
  end
end
