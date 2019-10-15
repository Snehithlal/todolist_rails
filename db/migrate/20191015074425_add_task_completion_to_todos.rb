class AddTaskCompletionToTodos < ActiveRecord::Migration[6.0]
  def change
    add_column :todos, :old_status, :bigInt, default: 0
    add_column :todos, :new_status, :bigInt, default: 0
  end
end
