class Todo < ApplicationRecord
  has_many :user
  has_many :comments, dependent: :destroy
  validates_presence_of :body

  scope :active_inactive, lambda { |keyword| where(active: keyword)}
  scope :search, lambda { |keyword| where("body LIKE ?", keyword).order(id: :desc) }
  scope :user, lambda { |keyword| where(user_id: keyword.id) }
  scope :up, lambda { |current_todo| where("priority > ?",current_todo.priority).limit(1) }
  scope :down, lambda { |current_todo| where("priority < ?",current_todo.priority).order(priority: :desc).limit(1) }
  scope :pagination, lambda {
     |keyword| order(priority: :desc).paginate(page: keyword, per_page: 4)
   }

  #sort todo based on id for listing newest first
  def self.sorted_todos
    Todo.all.order(priority: :desc)
  end
  #

  #each time updates position
  def self.update_position
    Todo.order(:updated_at).each.with_index(1) do |todo, index|
      todo.update_column :priority, index
    end
  end

  #position_up
  def self.position_up(current_todo,status,current_user)
    previous_todo = Todo.active_inactive(status).user(current_user).up(current_todo)
    previous = previous_todo[0][:priority]
    current = current_todo[:priority]
    current_todo.update(priority: previous)
    previous_todo.update(priority: current)
  end

  #position_down
  def self.position_down(current_todo,status,current_user)
    next_todo = Todo.active_inactive(status).user(current_user).down(current_todo)
    next_priority = next_todo[0][:priority]
    current_priority = current_todo[:priority]
    current_todo.update(priority: next_priority)
    next_todo.update(priority: current_priority)
  end

  #search for index
  def self.search_index
    return Todo.order(:priority).last.priority
  end

end
