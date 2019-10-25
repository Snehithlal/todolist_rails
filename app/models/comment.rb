# frozen_string_literal: true

class Comment < ApplicationRecord
  validates_presence_of :body
  belongs_to :todo
  belongs_to :user

  #check whether the comment from commentbox or progressbar
  def self.create_comment(params, comment_params, current_user)
    todo = Todo.find_by(id: params[:todo_id])
    if params.key?(:comment)
      comment = todo.comments.create(comment_params)
    else
      generated_comment = generate_comment(params)
      comment = todo.comments.create(body: generated_comment, user_id: current_user.id)
      todo.update(task_status: params[:new_status])
      comment
    end
    Comment.joins(:user).select('users.*,comments.*').where('comments.todo_id = ? and comments.id=?', todo.id, comment.id)[0]
  end

  # comment created using status of progressbar
  def self.generate_comment(params)
    unless params[:new_status] == params[:old_status]
      if params[:new_status] == '100'
        comment = 'status of the task changed to <span class="green">done</span>'
      else
        comment = "task has been updated from <span class=\"green\">#{params[:old_status]}%</span> to <span class=\"green\">#{params[:new_status]}%.</span>"
      end
    end
    comment
  end
end
