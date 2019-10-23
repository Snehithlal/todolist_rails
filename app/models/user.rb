class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :shares
  has_many :todos, :through =>:shares, dependent: :destroy
  has_many :comments, dependent: :destroy
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  scope :todo_owner, lambda{ |todoid,owner| where("todo_id=? and is_owner=?",todoid,owner) }
  scope :userjoinshares, lambda {joins(:shares).select("users.name")}
end
