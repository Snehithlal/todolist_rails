class TodosController < ApplicationController
  respond_to :js
  respond_to :html

  def index
    @list_todos = Todo.check_params(params,current_user)
  end

  def new
    @todo = Todo.new
  end

  #create todo and update priority added with last priority
  def create
    todo = Todo.new(todo_params)
    Todo.add_priority(todo,current_user)
    @todolist= Todo.print_todos(true,params,current_user).where(id: todo.id)[0]
    @count = Todo.joins(:shares).user(current_user).is_active(true).count
  end

  #in show page search is null then normal show
  def search
    @list_todos = Todo.search_params(params,current_user)
  end

  #to change active status by checking db value when clicked tickbox
  def status_update
    todo = Todo.find_by(id: params[:id])
    @todo = Todo.status_update(todo)
  end


  #destroy parameters
  def destroy
    @todo = Todo.find_by(id: params[:id])
    @todo.destroy
    url = Rails.application.routes.recognize_path(request.referrer)
    redirect_to root_path if (url[:action] == 'show')
  end

  #show todo link and comments
  def show
    @todo_details = (Todo.todojoinshare.sharedtodo(params[:id],current_user.id))[0]
    @comments = @todo_details.comments
    @shared_with = User.joins(:shares).select("users.name").todo_owner(params[:id],false)
  end

  #to change prority
  def change_position
    @todo = (Todo.todojoinshare.sharedtodo(params[:id],current_user.id))[0]
    @arrow = Todo.position_update(params,current_user)
  end

  private

  def todo_params
    params.require(:todo).permit(:body, :active).merge("user_id" => current_user.id)
  end

end
