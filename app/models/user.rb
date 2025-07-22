class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :employee, optional: true

  # Override Devise validations to remove email requirement
  validates :username, presence: true, uniqueness: { case_sensitive: false }

  # Disable email validation completely
  def email_required?
    false
  end

  def email_changed?
    false
  end

  def will_save_change_to_email?
    false
  end

  # Use username for authentication
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if username = conditions.delete(:username)
      where(username: username).first
    elsif conditions.has_key?(:username)
      where(conditions.to_h).first
    end
  end
end
