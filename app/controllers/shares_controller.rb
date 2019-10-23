class SharesController < ApplicationController
  skip_before_action :verify_authenticity_token


  def index
    @users = User.where("id <>?",params[:current_user_id])
    @current_user = params[:current_user_id]
    @shared_users = Share.select("user_id").todo_owner(params[:todo_id],false)
    respond_to :js
  end

  #create share entry
  def create
    @array = params[:user_array]
    check_user(@array,params[:todo_id])
    @shared_with = User.joins(:shares).select("users.name").todo_owner(params[:todo_id],false)
  end

  #add share and remove share
  def check_user(shared_users,todo_id)
    @shared_todos = Share.select("user_id").todo_owner(params[:todo_id],false)

    #for creating share bt searchin shared array
    shared_users.each do |user|
      break if user == "0"
    share = @shared_todos.find_by(user_id:user)
      if share.nil?
        current_priority = Todo.search_index(user)
        @share = Share.new(user_id: user,todo_id: todo_id, is_owner: false,priority:current_priority+1)
        @share.save
      end
    end

    #remove users from unchecked array
    @shared_todos.each do |share|
      unless shared_users.include?("#{share.user_id}")
        @share = Share.find_by(user_id: share.user_id,todo_id: todo_id)
        @share.destroy
      end
    end

  end

end
