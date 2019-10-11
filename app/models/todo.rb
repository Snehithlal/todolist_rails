class Todo < ApplicationRecord
  has_many :user
  has_many :comments, dependent: :destroy
  validates_presence_of :body

  scope :active_todos, -> { where(:active => true).order(priority: :desc) }
  scope :inactive_todos, -> { where(:active => false).order(priority: :desc) }
  scope :search, lambda { |keyword| where("body LIKE ?", keyword).order(id: :desc) }
  scope :user, lambda { |keyword| where(user_id: keyword.id) }
  # scope :active_todos, lambda { |keyword| where(:active => true).order(priority: :desc) .where(user_id: keyword.id) }

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

  #search for index
  def self.search_index
    return Todo.order(:priority).last.priority
  end

  #position_up
  def self.position_up(current_todo,array_todo)
      current_index = array_todo.find_index(current_todo)
      previous_todo = array_todo[current_index-1]
      previous = previous_todo[:priority]
      current = current_todo[:priority]
      current_todo.update(priority: previous)
      previous_todo.update(priority: current)
  end

  #position_down
  def self.position_down(current_todo,array_todo)
      current_index = array_todo.find_index(current_todo)
      next_todo = array_todo[current_index + 1]
      next_priority = next_todo[:priority]
      current_priority = current_todo[:priority]
      current_todo.update(priority: next_priority)
      next_todo.update(priority: current_priority)
  end

end
