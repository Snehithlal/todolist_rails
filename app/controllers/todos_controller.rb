class TodosController < ApplicationController
  respond_to :js
  respond_to :html

  def index
    # @todolists = Todo.all
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
      @list_todos = print_todos(true)
    end
  end

  #create todo and update priority
  def create
    # TODO: add after create
    @user = User.find(current_user.id)
    @todolist = Todo.new(todo_params)
    @todolist.save
    @share = Share.new(user_id: current_user.id,todo_id: @todolist.id, is_owner: true)
    @share.save
    current_priority = Todo.search_index(current_user.id)
    @share.update(priority: current_priority+1)
    @todolist = print_todos(true).where(id: @todolist.id)[0]
    @count = Todo.joins(:shares).where("shares.user_id=? and todos.active=true",current_user).count
  end

  #calling from each method
  def print_todos(status)
    return  Todo.joins(:shares).select("shares.*,todos.*").where("shares.user_id=?",current_user.id).pagination(params[:page]) if status == ""
    return Todo.joins(:shares).select("shares.*,todos.*").where("todos.active=? and shares.user_id=?",status,current_user.id).pagination(params[:page])
  end

  #search for body in the list
  def search

    if params[:search] == ""
      @list_todos = print_todos(true)
    else
      @list_todos = print_todos("").search("%#{params[:search]}%").paginate(page: params[:page], per_page: 4)
    end

  end

  #to change active status by checking db value
  def status_update
    @todolist = Todo.find(params[:id])
    @todolist.active? ? @todolist.update(active: false) : @todolist.update(active: true)
    @todolist.save
  end


  #destroy parameters
  def destroy
    @todolist = Todo.find(params[:id])
    @todolist.destroy
    url = Rails.application.routes.recognize_path(request.referrer)
    redirect_to root_path if (url[:action] == 'show')

  end

  #show todo link and comments
  def show
    @todo_details = (Todo.joins(:shares).select("shares.*,todos.*").where("todos.id=? and shares.user_id=?",params[:id],current_user.id))[0]
    @comments = @todo_details.comments
    @commenter =  User.find(@todo_details[:user_id])[:name]
    @shared_with = User.joins(:shares).select("users.name").where("todo_id=?and is_owner=false",params[:id])
  end

  #to change prority
  def change_position
    # @todo = Todo.find(params[:id])
    @todo = (Todo.joins(:shares).select("shares.*,todos.*").where("todos.id=? and shares.user_id=?",params[:id],current_user.id))[0]
    case params[:arrow]
    when "up"
      @arrow = "up"
      Todo.position_up(@todo,current_user)
    when "down"
      @arrow = "down"
      Todo.position_down(@todo,current_user)
    end
  end

  private

  def todo_params
    params.require(:todo).permit(:body, :active).merge("user_id" => current_user.id)
  end


end
