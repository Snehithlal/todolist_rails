class TodolistsController < ApplicationController

  #class variable for storing active status
  @@active_status = 0

  def index
    @todolists = Todolist.all
    @list_todos = list_todos
    @active_status = @@active_status
  end

  def new
    @todolist = Todolist.new
  end

  def create
    @todolist = Todolist.new(todolist_params)
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
      Todolist.active_todos
    when 1
      Todolist.inactive_todos
    else
      Todolist.sorted_todos
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
    @list_todos=Todolist.search_body(search_pattern,@@active_status)
    render 'index'

  end

  #to change active status
  def update
    @todolist = Todolist.find(params[:id])
    params[:active] == "true" ? @todolist.update(active: false) : @todolist.update(active: true)
    @todolist.save
    redirect_to root_path
  end

  #destroy parameters
  def destroy
    @todolist = Todolist.find(params[:id])
    @todolist.destroy
    redirect_to root_path
  end

  private

  def todolist_params
    params.require(:todolist).permit(:body, :active).merge("user_id" => current_user.id)
  end

  def search_params
     params.require(:search_data).permit(:search)
  end

end
