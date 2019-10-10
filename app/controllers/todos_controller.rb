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
      # @list_todos = Todo.search("%#{params[:search]}%").user(current_user)
    elsif params.key?(:active)
      @list_todos = params[:active] =="inactive" ? Todo.inactive_todos :  Todo.active_todos
      @list_todos = @list_todos.user(current_user)
    else
      @list_todos = print_todos(true)
    end
  end

  #calling from each method
  def print_todos(status)
    @list_todos = status == true ? Todo.active_todos :  Todo.inactive_todos
    @list_todos = @list_todos.user(current_user)
  end

  #create todo and update priority
  def create
    @todolist = Todo.new(todo_params)
    current_priority = Todo.search_index
    @todolist.update(priority: current_priority+1)
    if @todolist.save
      print_todos(true)
    else
      print_todos(true)
    end
  end

  #search for body in the list
  def search
    @list_todos = Todo.search("%#{params[:search]}%").user(current_user)
  end

  #to change active status by checking db value
  def status_update
    @todolist = Todo.find(params[:id])
    status = @todolist.active
    @todolist.active? ? @todolist.update(active: false) : @todolist.update(active: true)
    @todolist.save
    # Todo.update_position
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
    @todo = Todo.find(params[:id])
    current_todo = @todo
    status = current_todo.active
    array_todo = current_todo.active? ? Todo.active_todos.to_a : Todo.inactive_todos.to_a
    case params[:arrow]
    when "up"
      @arrow = "up"
      Todo.position_up(current_todo,array_todo)
    when "down"
      @arrow = "down"
      Todo.position_down(current_todo,array_todo)
    end
  end

  private

  def todo_params
    params.require(:todo).permit(:body, :active).merge("user_id" => current_user.id)
  end


end
