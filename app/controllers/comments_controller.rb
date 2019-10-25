# frozen_string_literal: true

class CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  respond_to :js

  # create comment from comment box and progressbar
  def create
    comment_params = 0 unless comment_params.present?
    @comment = Comment.create_comment(params,comment_params,current_user)
  end

  private

  def comment_params
    params.require(:comment).permit(:body).merge(user_id: current_user.id)
  end
end
