class User < ApplicationRecord
  # Use UUID as primary key
  self.primary_key = 'id'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  enum :role, { admin: 0, operation: 1, supervisor: 2 }

  validates :name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true

  def can_create_users?
    admin? || supervisor?
  end
end
