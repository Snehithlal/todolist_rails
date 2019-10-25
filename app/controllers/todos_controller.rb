
class TodosController < ApplicationController
  respond_to :js
  respond_to :html
  before_action :find_todo, only: %i[destroy status_update]
  before_action :find_todo_details, only: %i[show change_position]
  helper FormatedTime

  def index
    @list_todos = Todo.check_params(params, current_user)
  end

  def new
    @todo = Todo.new
  end

  # create todo and update priority added with last priority
  def create
    @todolist = Todo.create_todo(todo_params, current_user)
    @count = Todo.joins(:shares).user(current_user).is_active(true).count
  end

  # in show page search is null then normal show
  def search
    @list_todos = Todo.search_params(params, current_user)
  end

  # to change active status by checking db value when clicked tickbox
  def status_update
    @todo_details = Todo.status_update(@todo)
  end

  # destroy parameters
  def destroy
    @todo.destroy
    url = Rails.application.routes.recognize_path(request.referrer)
    redirect_to root_path if url[:action] == 'show'
  end

  # show todo link and comments
  def show
    @comments = User.joins(:comments).select('comments.*,users.*').where('comments.todo_id = ?', @todo_details.id)
    @shared_with = User.joins(:shares).select('users.name').todo_owner(params[:id], false)
  end

  # to change prority
  def change_position
    @arrow = Todo.position_update(params, current_user)
  end

  private

  def todo_params
    params.require(:todo).permit(:body, :active).merge('user_id' => current_user.id)
  end

  def find_todo
    @todo = Todo.find_by(id: params[:id])
  end

  def find_todo_details
    @todo_details = Todo.todo_join_share.sharedtodo(params[:id], current_user.id)[0]
  end
end
