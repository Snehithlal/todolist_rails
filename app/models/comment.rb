class Comment < ApplicationRecord
  validates_presence_of :body
  belongs_to :todo
  belongs_to :user
end
