# frozen_string_literal: true

class Todo < ApplicationRecord
  has_many :shares
  has_many :comments, dependent: :destroy
  has_many :users, through: :shares, dependent: :destroy
  validates_presence_of :body

  scope :todo_join_share, -> { joins(:shares).select('shares.*,todos.*') }
  scope :is_active, ->(keyword) { where('todos.active=?', keyword) }
  scope :user, ->(user) { where('shares.user_id=?', user.id) }
  scope :search, ->(keyword) { where('body LIKE ?', keyword).order(id: :desc) }
  scope :up, ->(current_todo) { select('todos.*,shares.priority').where('priority>?', current_todo.priority).order(priority: :asc).limit(1)[0] }
  scope :down, ->(current_todo) { select('todos.*,shares.priority').where('priority<?', current_todo.priority).order(priority: :desc).limit(1)[0] }
  scope :pagination, ->(keyword) { order(priority: :desc).paginate(page: keyword, per_page: 4) }
  scope :sharedtodo, ->(todoid, userid) { where('todos.id=? and shares.user_id=?', todoid, userid) }

  # create todo and update priority
  def self.create_todo(todo_params, current_user)
    todo = Todo.new(todo_params)
    if todo.save
      Share.add_priority(todo, current_user)
      Todo.print_todos(true, todo_params, current_user).where(id: todo.id)[0]
    end
  end

  # check whether search or index default index
  def self.check_params(params, current_user)
    if params.key?(:search)
      search
    elsif params.key?(:active)
      print_todos(params[:active] == 'active', params, current_user)
    else
      print_todos(true, params, current_user)
    end
  end

  # calling from each method
  def self.print_todos(status, params, current_user)
    if status == 0
      todo_join_share.user(current_user).pagination(params[:page])
    else
      todo_join_share.is_active(status).user(current_user).pagination(params[:page])
    end
  end

  # positionchange
  def self.position_update(params, current_user)
    todo = Todo.todo_join_share.sharedtodo(params[:id], current_user.id)[0]
    case params[:arrow]
    when 'up'
      arrow = 'up'
      position_up(todo, current_user)
    when 'down'
      arrow = 'down'
      position_down(todo, current_user)
    end
    arrow
  end

  # position_up
  def self.position_up(current_todo, current_user)
    previous_todo = Todo.joins(:shares).is_active(current_todo.active?).user(current_user).up(current_todo)
    previous_priority = previous_todo[:priority]
    current_priority = current_todo[:priority]
    current_todo.shares.where(user_id: current_user.id)[0].update(priority: previous_priority)
    previous_todo.shares.where(user_id: current_user.id)[0].update(priority: current_priority)
  end

  # position_down
  def self.position_down(current_todo, current_user)
    next_todo = Todo.joins(:shares).is_active(current_todo.active?).user(current_user).down(current_todo)
    next_priority = next_todo[:priority]
    current_priority = current_todo[:priority]
    current_todo.shares.where(user_id: current_user.id)[0].update(priority: next_priority)
    next_todo.shares.where(user_id: current_user.id)[0].update(priority: current_priority)
  end

  # search for index
  def self.search_index(current_user_id)
    user = User.find(current_user_id)
    if user.shares.order(:priority).empty?
      0
    else
      user.shares.order(:priority).last.priority
    end
  end

  # search
  def self.search_params(params, current_user)
    if params[:search].present?
      print_todos(0, params, current_user).search("%#{params[:search]}%").paginate(page: params[:page], per_page: 4)
    else
      print_todos(true, params, current_user)
    end
  end

  # status_update
  def self.status_update(todo)
    todo.update(active: !todo.active?)
    todo
  end
end
