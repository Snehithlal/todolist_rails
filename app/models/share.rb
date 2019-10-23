class Share < ApplicationRecord
  belongs_to :user
  belongs_to :todo

  scope :todo_owner, lambda{ |todoid,owner| where("todo_id=? and is_owner=?",todoid,owner) }
end
