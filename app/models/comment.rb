class Comment < ApplicationRecord
  validates_presence_of :body
  belongs_to :todo
  belongs_to :user

  def self.create_comment(params,comment_params)
    comment = generate_comment(params)
    @todo = Todo.find_by(id: params[:todo_id])
    
    if params.key?(:comment)
      @comment = @todo.comments.create(comment_params)
    else
      @comment = @todo.comments.create(body: comment, user_id: comment_params[:user_id])
      @todo.update(task_status: params[:new_status])
    end
  end

  def self.generate_comment(params)
    if params[:new_status] != params[:old_status]
      comment = "task has been updated from <span class=\"green\">#{params[:old_status]}%</span> to <span class=\"green\">#{params[:new_status]}%.</span>"
      if params[:new_status] == "100"
        comment = "status of the task changed to <span class=\"green\">done</span>"
      end
    end
    comment
  end

end
