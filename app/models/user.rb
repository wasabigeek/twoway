class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :connections, dependent: :destroy

  #
  # Used in the OmniauthCallbacksController to find or create a successfully authenticated User.
  #
  # @param [OmniAuth::AuthHash] access_token - https://github.com/zquestz/omniauth-google-oauth2#auth-hash
  #
  # @return [User]
  #
  def self.from_omniauth(access_token, scope: nil)
    data = access_token.info
    user = User.where(email: data['email']).first

    # Create users if they don't exist
    unless user
      user = User.create(
        email: data['email'],
        password: Devise.friendly_token[0,20]
      )
      user.connections.create!(
        access_token: access_token.credentials['token'],
        refresh_token: access_token.credentials['refresh_token'],
        provider: access_token.provider,
        scope: scope
      )
    end

    user
  end
end
