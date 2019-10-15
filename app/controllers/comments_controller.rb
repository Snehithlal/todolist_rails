class CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  respond_to :js
  def create
    if params[:new_status] != params[:old_status]
      comment = "task has been updated from #{params[:old_status]}% to #{params[:new_status]}%."
      if params[:new_status] == "100"
        comment = "status of the task changed to done"
      end
    end
    @todo = Todo.find(params[:todo_id])
    if params.key?(:comment)
      @comment = @todo.comments.create(comment_params)
    else
      @comment = @todo.comments.create(body: comment, user_id: current_user.id)
      @todo.update(task_status: params[:new_status])
    end
    @comments = @todo.comments
    @commenter =  User.find(@todo[:user_id])[:name]
  end

  private
    def comment_params
      params.require(:comment).permit(:body).merge(user_id: current_user.id)
    end

end
