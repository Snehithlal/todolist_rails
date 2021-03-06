# frozen_string_literal: true

class Share < ApplicationRecord
  belongs_to :user
  belongs_to :todo

  scope :todo_owner, ->(todoid, owner) { where('todo_id=? and is_owner=?', todoid, owner) }

  def self.add_priority(todo, current_user)
    share = Share.new(user_id: current_user.id, todo_id: todo.id, is_owner: true)
    share.save
    current_priority = Todo.search_index(current_user.id)
    share.update(priority: current_priority + 1)
  end

  def self.update_shared_users(params)
    @shared_users = params[:user_array]
    @shared_todos = Share.select('user_id').todo_owner(params[:todo_id], false)
    add_to_share(params)
    remove_share(params)
  end

  def self.add_to_share(params)
    @shared_users.each do |user|
      break if user == '0'

      share = @shared_todos.find_by(user_id: user)
      next unless share.nil?

      current_priority = Todo.search_index(user)
      add_share = Share.new(user_id: user, todo_id: params[:todo_id], is_owner: false, priority: current_priority + 1)
      add_share.save
    end
  end

  def self.remove_share(params)
    @shared_todos.each do |share|
      unless @shared_users.include?(share.user_id.to_s)
        remove_share = Share.find_by(user_id: share.user_id, todo_id: params[:todo_id])
        remove_share.destroy
      end
    end
  end
end
