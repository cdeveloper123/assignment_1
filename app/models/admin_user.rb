class AdminUser < ApplicationRecord
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, presence: true

  # Allowlist searchable attributes for Ransack (ActiveAdmin filters)
  def self.ransackable_attributes(auth_object = nil)
    [
      "id",
      "email",
      "first_name",
      "last_name",
      "created_at",
      "updated_at"
    ]
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end 