class User < ApplicationRecord
  # Use UUID as primary key
  self.primary_key = 'id'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  enum :role, { admin: 0, operation: 1, supervisor: 2 }
  enum :status, { active: 0, inactive: 1 }

  validates :name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true

  after_commit :create_inventory_preferences, on: :create

  has_and_belongs_to_many :branches
  # Active Storage for user avatar
  has_one_attached :avatar

  has_one :inventory_preferences, dependent: :destroy
  has_many :inventory_transactions, dependent: :destroy

  # Avatar validation using custom method
  validate :avatar_validation

  # Search scope
  scope :search, ->(term) {
    return all if term.blank?

    where(
      'name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?',
      "%#{term}%", "%#{term}%", "%#{term}%"
    )
  }

  def can_create_users?
    admin? || supervisor?
  end

  def self.generate_temporary_password
    # Generate a secure temporary password
    # Format: 3 uppercase letters + 3 numbers + 3 lowercase letters
    upper = (0...3).map { ('A'..'Z').to_a[rand(26)] }.join
    numbers = (0...3).map { rand(10) }.join
    lower = (0...3).map { ('a'..'z').to_a[rand(26)] }.join

    "#{upper}#{numbers}#{lower}"
  end

  private

  def create_inventory_preferences
    create_inventory_preferences!
  end

  def avatar_validation
    return unless avatar.attached?

    # Validate content type
    unless avatar.content_type.in?(%w[image/jpeg image/jpg image/png image/gif])
      errors.add(:avatar, 'must be a JPEG, PNG, or GIF image')
    end

    # Validate file size (5MB max)
    if avatar.byte_size > 5.megabytes
      errors.add(:avatar, 'should be less than 5MB')
    end
  end
end
