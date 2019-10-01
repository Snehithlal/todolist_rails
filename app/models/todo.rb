class Todo < ApplicationRecord
  has_many :user
  validates_presence_of :body

  #sort active todos
  def self.active_todos
    Todo.where(active: true).order(priority: :desc)
  end

  #sort inactive todos
  def self.inactive_todos
    Todo.where(active: false).order(priority: :desc)
  end

  #sort todo based on id for listing newest first
  def self.sorted_todos
    Todo.all.order(priority: :desc)
  end

  #search for keywords
  def self.search_body(search_body,status)
    case status
    when 0
      Todo.active_todos.where("body LIKE ?", search_body).order(id: :desc)
    when 1
      Todo.inactive_todos.where("body LIKE ?", search_body).order(id: :desc)
    else
      Todo.sorted_todos.where("body LIKE ?", search_body).order(id: :desc)
    end
  end

  #each time updates position
  def self.update_position
    Todo.order(:updated_at).each.with_index(1) do |todo, index|
      todo.update_column :priority, index
    end
  end
end
