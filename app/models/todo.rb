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

  #current_user
  # def self.logined_user(current_user)
  #   @current_user = current_user
  # end
  #
  # def self.parameters(params)
  #   @params = params
  # end

  def self.add_priority(todo,current_user)
    share = Share.new(user_id: current_user.id,todo_id: todo.id, is_owner: true)
    share.save
    current_priority = Todo.search_index(current_user.id)
    share.update(priority: current_priority+1)
  end

  #check whether search or index default index
  def self.check_params(params,current_user)
    if params.key?(:search)
      search
    elsif params.key?(:active)
      print_todos(params[:active] == "active",params,current_user)
    else
      print_todos(true,params,current_user)
    end
  end


  #calling from each method
  def self.print_todos(status,params,current_user)
    return  self.todojoinshare.user(current_user).pagination(params[:page]) if status == 0
    return self.todojoinshare.is_active(status).user(current_user).pagination(params[:page])
  end

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
    user = User.find(current_user_id)
    if (user.shares.order(:priority)).empty?
      return 0
    else
      return user.shares.order(:priority).last.priority
    end
  end

end
