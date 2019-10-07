class TodosController < ApplicationController

  respond_to :js

  #class variable for storing active status
  @@active_status = 0

  def index
    @todolists = Todo.all
    @list_todos = print_todos
    @active_status = @@active_status
  end

  def new
    @todolist = Todo.new
  end

  #calling from each method
  def print_todos
    @list_todos = list_todos.where(user_id: current_user.id)
  end

  def create
    @todolist = Todo.new(todo_params)
    current_priority = Todo.search_index
    @todolist.update(priority: current_priority+1)
    if @todolist.save
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
    search_pattern = "%#{params[:search]}%"
    @list_todos = Todo.search_body(search_pattern,@@active_status).where(user_id: current_user.id)

  end

  #to change active status by checking db value
  def status_update
    @todolist = Todo.find(params[:id])
    @todolist.active? ? @todolist.update(active: false) : @todolist.update(active: true)
    @todolist.save
    Todo.update_position
    print_todos
    # render :update do |page|
    #   page.replace_html  'todolist', :partial => 'todolist', :collection => @list_todos
    # end
  end


  #destroy parameters
  def destroy
    @todolist = Todo.find(params[:id])
    @todolist.destroy
    Todo.update_position
    print_todos
  end

  #show todo link and comments
  def show
    @todo_details = Todo.find(params[:id])
    @comments = @todo_details.comments
  end

  #to change prority
  def change_position
    current_todo = Todo.find(params[:id])
    array_todo = Todo.active_todos.to_a
    array_todo = Todo.inactive_todos.to_a if !current_todo.active?
    case params[:arrow]
    when "up"
      position_up(current_todo,array_todo)
    when "down"
      position_down(current_todo,array_todo)
    end
    print_todos
    # redirect_to root_path
  end

  #position_up
  def position_up(current_todo,array_todo)
      current_index = array_todo.find_index(current_todo)
      previous_todo = array_todo[current_index-1]
      previous = previous_todo[:priority]
      current = current_todo[:priority]
      current_todo.update(priority: previous)
      previous_todo.update(priority: current)
  end

  #position_down
  def position_down(current_todo,array_todo)
      current_index = array_todo.find_index(current_todo)
      next_todo = array_todo[current_index + 1]
      next_priority = next_todo[:priority]
      current_priority = current_todo[:priority]
      current_todo.update(priority: next_priority)
      next_todo.update(priority: current_priority)
  end

  private

  def todo_params
    params.require(:todo).permit(:body, :active).merge("user_id" => current_user.id)
  end


end
