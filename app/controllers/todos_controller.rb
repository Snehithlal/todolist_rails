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

  #check whether search or index default index
  def check_params(params)
    if params.key?(:search)
      search
    elsif params.key?(:active)
      @list_todos =  print_todos(params[:active] == "active")
    else
      @list_todos = print_todos(true)
    end
  end

  #create todo and update priority added with last priority
  def create
    # TODO: add after create
    @user = User.find_by(id: current_user.id)
    @todolist = Todo.new(todo_params)
    @todolist.save
    @share = Share.new(user_id: current_user.id,todo_id: @todolist.id, is_owner: true)
    @share.save
    current_priority = Todo.search_index(current_user.id)
    @share.update(priority: current_priority+1)
    @todolist = print_todos(true).where(id: @todolist.id)[0]
    @count = Todo.joins(:shares).user(current_user).is_active(true).count
  end

  #calling from each method
  def print_todos(status)
    return  Todo.todojoinshare.user(current_user).pagination(params[:page]) if status == 0
    return Todo.todojoinshare.is_active(status).user(current_user).pagination(params[:page])
  end

  #search for body in the list
  #in show page search is null then normal show
  def search

    if params[:search].present?
      @list_todos = print_todos(0).search("%#{params[:search]}%").paginate(page: params[:page], per_page: 4)
    else
      @list_todos = print_todos(true)
    end

  end

  #to change active status by checking db value when clicked tickbox
  def status_update
    @todolist = Todo.find_by(id: params[:id])
    @todolist.update(active: !@todolist.active?)
    @todolist.save
  end


  #destroy parameters
  def destroy
    @todolist = Todo.find_by(id: params[:id])
    @todolist.destroy
    url = Rails.application.routes.recognize_path(request.referrer)
    redirect_to root_path if (url[:action] == 'show')

  end

  #show todo link and comments
  def show
    @todo_details = (Todo.todojoinshare.sharedtodo(params[:id],current_user.id))[0]
    @comments = @todo_details.comments
    # @commenter =  User.find_by(name: @todo_details[:user_id])[:name]
    @shared_with = User.joins(:shares).select("users.name").todo_owner(params[:id],false)
  end

  #to change prority
  def change_position
    @todo = (Todo.todojoinshare.sharedtodo(params[:id],current_user.id))[0]
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
