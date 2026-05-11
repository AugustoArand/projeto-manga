class UserSession < ApplicationRecord
  belongs_to :user

  TOKEN_EXPIRY = 30.days

  before_create :generate_token

  scope :active, -> { where("expires_at > ?", Time.current) }

  def self.create_for(user, device_info: nil)
    create!(user: user, expires_at: TOKEN_EXPIRY.from_now, device_info: device_info)
  end

  def self.find_active(token)
    active.find_by(token: token)
  end

  def expired?
    expires_at < Time.current
  end

  private

  def generate_token
    self.token = loop do
      t = SecureRandom.urlsafe_base64(32)
      break t unless UserSession.exists?(token: t)
    end
  end
end
