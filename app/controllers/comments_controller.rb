# frozen_string_literal: true

class CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  helper FormatedTime
  respond_to :js

  # create comment from comment box and progressbar
  def create
    @comment = Comment.create_comment(params,comment_params,current_user)
  end

  private

  def comment_params
    if params.key?(:comment)
      params.require(:comment).permit(:body).merge(user_id: current_user.id)
    else
      0
    end
  end
end
