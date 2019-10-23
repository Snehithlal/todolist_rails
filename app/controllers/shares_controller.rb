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
    Share.update_shared_users(params)
    @shared_with = User.userjoinshares.todo_owner(params[:todo_id],false)
  end

end
