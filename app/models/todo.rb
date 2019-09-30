class Todo < ApplicationRecord
  has_many :user
  validates_presence_of :body

  #sort active todos
  def self.active_todos
    Todo.where(active: true).order(id: :desc)
  end

  #sort inactive todos
  def self.inactive_todos
    Todo.where(active: false).order(id: :desc)
  end

  #sort todo based on id for listing newest first
  def self.sorted_todos
    Todo.all.order(id: :desc)
  end

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
end
