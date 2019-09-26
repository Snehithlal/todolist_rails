class Todolist < ApplicationRecord
  has_many :user
  validates_presence_of :body
end
