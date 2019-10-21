class Todo < ApplicationRecord
  has_many :shares
  has_many :comments, dependent: :destroy
  has_many :users, :through =>:shares, dependent: :destroy
  validates_presence_of :body

  scope :active_inactive, lambda { |keyword| where("todos.active=?",keyword)}
  scope :search, lambda { |keyword| where("body LIKE ?", keyword).order(id: :desc) }
  scope :user, lambda { |keyword| where(user_id: keyword.id) }
  scope :up, lambda { |current_todo| where("priority > ?",current_todo.priority).limit(1) }
  scope :down, lambda { |current_todo| where("priority < ?",current_todo.priority).order(priority: :desc).limit(1) }
  scope :pagination, lambda { |keyword| order(priority: :desc).paginate(page: keyword, per_page: 4) }

  #sort todo based on id for listing newest first
  def self.sorted_todos
    Todo.all.order(priority: :desc)
  end
  #

  #each time updates position
  def self.update_position(current_user_id)
    Todo.where(user_id: current_user_id).order(:updated_at).each.with_index(1) do |todo, index|
      todo.update_column :priority, index
    end
  end

  #position_up
  def self.position_up(current_todo,current_user)
    # previous_todo = Todo.active_inactive(current_todo.active).user(current_user).up(current_todo)
    previous_todo = Todo.joins(:shares).select("todos.*,shares.priority").where("shares.user_id=? and todos.active=? and priority>?",current_user.id,current_todo.active?,current_todo.priority).order(priority: :asc).limit(1)[0]
    previous_priority = previous_todo[:priority]
    current_priority = current_todo[:priority]
    current_todo.shares.where(user_id: current_user.id)[0].update(priority: previous_priority)
    previous_todo.shares.where(user_id: current_user.id)[0].update(priority: current_priority)
  end

  #position_down
  def self.position_down(current_todo,current_user)
    # next_todo = Todo.active_inactive(current_todo.active).user(current_user).down(current_todo)
    next_todo = Todo.joins(:shares).select("todos.*,shares.priority").where("shares.user_id=? and todos.active=? and priority<?",current_user.id,current_todo.active?,current_todo.priority).order(priority: :desc).limit(1)[0]
    next_priority = next_todo[:priority]
    current_priority = current_todo[:priority]
    current_todo.shares.where(user_id: current_user.id)[0].update(priority: next_priority)
    next_todo.shares.where(user_id: current_user.id)[0].update(priority: current_priority)
  end

  #search for index
  def self.search_index(current_user_id)
    @user = User.find(current_user_id)
    if (@user.shares.order(:priority)).empty?
      return 0
    else
      return @user.shares.order(:priority).last.priority
    end
  end

end
