class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable, :recoverable, :rememberable
  devise :database_authenticatable, :registerable,
         :validatable

  has_many :polls, dependent: :destroy
  has_many :user_answers, dependent: :destroy
end
