class RemoveColumnOldStatus < ActiveRecord::Migration[6.0]
  def change
    remove_column :todos, :old_status
    rename_column :todos, :new_status, :task_status
  end
end
