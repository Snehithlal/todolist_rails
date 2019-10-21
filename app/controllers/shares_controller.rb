class SharesController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    @users = User.where("id <>?",params[:current_user_id])
    @current_user = params[:current_user_id]
    @shared_users = Share.select("user_id").where("todo_id=? and is_owner=false",params[:todo_id])
    respond_to :js
  end

  def create
    @array = params[:user_array]
    check_user(@array,params[:todo_id])
    @shared_with = User.joins(:shares).select("users.name").where("todo_id=?and is_owner=false",params[:todo_id])
  end

  def check_user(shared_users,todo_id)
    @shared_todos = Share.select("user_id").where("todo_id=? and is_owner=false",todo_id)
    shared_users.each do |user|
      break if user == "0"
    share = @shared_todos.find_by(user_id:user)
      if share.nil?
        current_priority = Todo.search_index(user)
        @share = Share.new(user_id: user,todo_id: todo_id, is_owner: false,priority:current_priority+1)
        @share.save
      end
    end
    @shared_todos.each do |share|
      unless shared_users.include?("#{share.user_id}")
        @share = Share.find_by(user_id: share.user_id,todo_id: todo_id)
        @share.destroy
      end
    end

  end

  def print_todos(status)
    return  Todo.joins(:shares).select("shares.*,todos.*").where("shares.user_id=?",current_user.id).pagination(params[:page]) if status == ""
    return Todo.joins(:shares).select("shares.*,todos.*").where("todos.active=? and shares.user_id=?",status,current_user.id).pagination(params[:page])
  end

end
