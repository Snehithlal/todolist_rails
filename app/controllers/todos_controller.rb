class TodosController < ApplicationController
  respond_to :js
  respond_to :html

  def index
    @todolists = Todo.all
    @list_todos = check_params(params)
  end

  def new
    @todolist = Todo.new
  end

  #check parameters
  def check_params(params)
    if params.key?(:search)
      search
    elsif params.key?(:active)
      @list_todos =  print_todos(params[:active] == "active")
    else
  p    @list_todos = print_todos(true)
    end
  end

  #create todo and update priority
  def create
    @todolist = Todo.new(todo_params)
    current_priority = Todo.search_index
    @todolist.update(priority: current_priority+1)
    @count = Todo.active_inactive(true).user(current_user).order(priority: :desc).count
  end

  #calling from each method
  def print_todos(status)
    @list_todos = Todo.active_inactive(status).user(current_user).pagination(params[:page])
  end

  #search for body in the list
  def search
    if params[:search] == ""
      @list_todos = print_todos(true)
    else
      @list_todos = Todo.search("%#{params[:search]}%").user(current_user).pagination(params[:page])
    end
  end

  #to change active status by checking db value
  def status_update
    @todolist = Todo.find(params[:id])
    status = @todolist.active
    @todolist.active? ? @todolist.update(active: false) : @todolist.update(active: true)
    @todolist.save
    Todo.update_position
    print_todos(status)
  end


  #destroy parameters
  def destroy
    @todolist = Todo.find(params[:id])
    status = @todolist.active
    @todolist.destroy
    print_todos(status)
  end

  #show todo link and comments
  def show
    @todo_details = Todo.find(params[:id])
    @comments = @todo_details.comments
  end

  #to change prority
  def change_position
    p "---current---"
    p @todo = Todo.find(params[:id])
    status = @todo.active
    case params[:arrow]
    when "up"
      @arrow = "up"
      Todo.position_up(@todo,@todo.active,current_user)
    when "down"
      @arrow = "down"
      Todo.position_down(@todo,@todo.active,current_user)
    end
  end

  private

  def todo_params
    params.require(:todo).permit(:body, :active).merge("user_id" => current_user.id)
  end


end
