class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  has_many :items, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :role, presence: true, inclusion: { in: %w[admin user] }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :admins, -> { where(role: 'admin') }
  scope :regular_users, -> { where(role: 'user') }

  # Callbacks
  before_save :normalize_email

  def admin?
    role == 'admin'
  end

  # For Devise JWT - generate JWT token payload
  def jwt_payload
    {
      id: id,
      email: email,
      name: name,
      role: role
    }
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
