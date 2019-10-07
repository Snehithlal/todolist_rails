class CommentsController < ApplicationController
  respond_to :js
  def create
    @todo = Todo.find(params[:todo_id])
    @comment = @todo.comments.create(comment_params)
    @comments = @todo.comments
  end

  private
    def comment_params
      params.require(:comment).permit(:body, :todo_id).merge(user_id: current_user.id)
    end

end
