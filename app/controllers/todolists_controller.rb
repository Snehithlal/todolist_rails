class TodolistsController < ApplicationController
  def index
    @todolists = Todolist.all
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
  def search

  end

  def update
    @todolist = Todolist.find(params[:id])
    p params(:active)
    @todolist.update()
    # @todo.update todo_params
    @todo.save
    redirect_to root_path
  end

  def destroy
    @todolist = Todolist.find(params[:id])
    @todolist.destroy
    redirect_to root_path
    # respond_to do |format|
    #   format.html { redirect_to root_path }
    #   format.json { head :no_content }
    #   format.js   { render :layout => false }
    # end
  end

  private

  def todolist_params
    params.require(:todolist).permit(:body, :active).merge("user_id" => current_user.id)

  end

end
