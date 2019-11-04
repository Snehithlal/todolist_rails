class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # attr_accessor :current_user
  has_many :shares
  has_many :todos, :through =>:shares, dependent: :destroy
  has_many :comments, dependent: :destroy
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  scope :todo_owner, lambda{ |todoid,owner| where("todo_id=? and is_owner=?",todoid,owner) }
  scope :userjoinshares, lambda {joins(:shares).select("users.name")}

  def get_todos
    todos.select("shares.*,todos.*").order(priority: :desc)
  end

  def get_active_todos(status)
    todos.select("shares.*,todos.*").is_active(status).order(priority: :desc)
  end

  def get_current_todo(todo_id)
    todos.select("shares.*,todos.*").where('todos.id=?',todo_id)
  end

  def get_next_todo(current_todo)
    todos.up(current_todo)
  end

  def get_previous_todo(current_todo)
    todos.down(current_todo)
  end
end
