class Todolist < ApplicationRecord
  has_many :user
  validates_presence_of :body

  #sort active todos
  def self.active_todos
    Todolist.where(active: true).order(id: :desc)
  end

  #sort inactive todos
  def self.inactive_todos
    Todolist.where(active: false).order(id: :desc)
  end

  #sort todo based on id for listing newest first
  def self.sorted_todos
    Todolist.all.order(id: :desc)
  end

  def self.search_body(search_body,status)
    case status
    when 0
      Todolist.active_todos.where("body LIKE ?", search_body).order(id: :desc)
    when 1
      Todolist.inactive_todos.where("body LIKE ?", search_body).order(id: :desc)
    else
      Todolist.sorted_todos.where("body LIKE ?", search_body).order(id: :desc)
    end
  end

end
