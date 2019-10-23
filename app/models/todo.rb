class Todo < ApplicationRecord
  has_many :shares
  has_many :comments, dependent: :destroy
  has_many :users, :through =>:shares, dependent: :destroy
  validates_presence_of :body

  scope :todojoinshare, lambda { joins(:shares).select("shares.*,todos.*") }
  scope :is_active, lambda { |keyword| where("todos.active=?",keyword)}
  scope :user, lambda { |user| where("shares.user_id=?",user.id)}
  scope :search, lambda { |keyword| where("body LIKE ?", keyword).order(id: :desc) }
  scope :up, lambda { |current_todo| select("todos.*,shares.priority").where("priority>?",current_todo.priority).order(priority: :asc).limit(1)[0] }
  scope :down, lambda{ |current_todo| select("todos.*,shares.priority").where("priority<?",current_todo.priority).order(priority: :desc).limit(1)[0]}
  scope :pagination, lambda { |keyword| order(priority: :desc).paginate(page: keyword, per_page: 4) }
  scope :sharedtodo, lambda {|todoid,userid| where("todos.id=? and shares.user_id=?",todoid,userid)}


  #position_up
  def self.position_up(current_todo,current_user)
    previous_todo = Todo.joins(:shares).is_active(current_todo.active?).user(current_user).up(current_todo)
    previous_priority = previous_todo[:priority]
    current_priority = current_todo[:priority]
    current_todo.shares.where(user_id: current_user.id)[0].update(priority: previous_priority)
    previous_todo.shares.where(user_id: current_user.id)[0].update(priority: current_priority)
  end

  #position_down
  def self.position_down(current_todo,current_user)
    next_todo = Todo.joins(:shares).is_active(current_todo.active?).user(current_user).down(current_todo)
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
