class CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  respond_to :js

  def create
    @comment = Comment.create_comment(params,comment_params)
  end

  private
    def comment_params
      params.require(:comment).permit(:body).merge(user_id: current_user.id)
    end

end
