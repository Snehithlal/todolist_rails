class CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  respond_to :js

  def create
    if params.key?(:comment)
      @comment = @todo.comments.create(comment_params)
    else
      @comment = Comment.create_comment(params,current_user)
    end
  end

  private
    def comment_params
      params.require(:comment).permit(:body).merge(user_id: current_user.id)
    end

end
