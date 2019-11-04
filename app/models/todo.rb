# frozen_string_literal: true

class Todo < ApplicationRecord
  has_many :shares
  has_many :comments, dependent: :destroy
  has_many :users, through: :shares, dependent: :destroy
  validates_presence_of :body


  scope :is_active, ->(keyword) { where('todos.active=?', keyword) }
  scope :user, ->(user) { where('shares.user_id=?', user.id) }
  scope :search, ->(keyword) { where('body LIKE ?', keyword).order(id: :desc) }
  scope :up, ->(current_todo) { select('todos.*,shares.priority').where('priority>?', current_todo[0].priority).is_active(current_todo[0].active?).order(priority: :asc).limit(1)[0] }
  scope :down, ->(current_todo) { select('todos.*,shares.priority').where('priority<?', current_todo[0].priority).is_active(current_todo[0].active?).order(priority: :desc).limit(1)[0] }
  scope :pagination, ->(keyword) { order(priority: :desc).paginate(page: keyword, per_page: 4) }

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
      current_user.get_todos.pagination(params[:page])
    else
      current_user.get_active_todos(status).pagination(params[:page])
    end
  end

  # positionchange
  def self.position_update(params, current_user)
    current_todo =  current_user.get_current_todo(params[:id])
    case params[:arrow]
    when 'up'
      new_todo = current_user.get_next_todo(current_todo)
    when 'down'
      new_todo = current_user.get_previous_todo(current_todo)
    end
    if new_todo.present?
      position_change(current_todo, new_todo, current_user)
      arrow = params[:arrow]
    end
    arrow
  end

  # positionchange
  def self.position_change(current_todo, new_todo, current_user)
    new_priority = new_todo[:priority]
    current_priority = current_todo[0].priority
    current_todo[0].shares.where(user_id: current_user.id)[0].update(priority: new_priority)
    new_todo.shares.where(user_id: current_user.id)[0].update(priority: current_priority)
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

end
