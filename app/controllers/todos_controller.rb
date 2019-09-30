class TodosController < ApplicationController

  #class variable for storing active status
  @@active_status = 0

  def index
    @todolists = Todo.all
    @list_todos = list_todos.where(user_id: current_user.id)
    @active_status = @@active_status
  end

  def new
    @todolist = Todo.new
  end

  def create
    @todolist = Todo.new(todo_params)
    if @todolist.save
      Todo.update_position
      redirect_to root_path, notice: "created"
    else
      redirect_to root_path, notice: "failed"
    end
  end

  #check condition
  def list_todos
    case @@active_status
    when 0
      Todo.active_todos
    when 1
      Todo.inactive_todos
    else
      Todo.sorted_todos
    end
  end

  #check radio button status
  def checkactive
     if params[:active] == "active"
       @@active_status = 0
     elsif params[:active] == "inactive"
       @@active_status = 1
     else
       @@active_status = 2
     end
     redirect_to root_path
  end

  #search for body in the list
  def search
    search_pattern = "%#{search_params[:search]}%"
    @list_todos=Todo.search_body(search_pattern,@@active_status)
    render 'index'

  end

  #to change active status
  def update
    @todolist = Todo.find(params[:id])
    params[:active] == "true" ? @todolist.update(active: false) : @todolist.update(active: true)
    @todolist.save
    Todo.update_position
    redirect_to root_path
  end

  #destroy parameters
  def destroy
    @todolist = Todo.find(params[:id])
    @todolist.destroy
    Todo.update_position
    redirect_to root_path
  end

  #position_up
  def position_up
    p "up"
  end

  #position_down
  def position_down
    p "down"
  end

  private

  def todo_params
    params.require(:todo).permit(:body, :active).merge("user_id" => current_user.id)
  end

  def search_params
     params.require(:search_data).permit(:search)
  end

end
