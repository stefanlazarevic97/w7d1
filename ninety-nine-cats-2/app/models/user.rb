# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  username        :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord
    validates :password_digest, :session_token, presence: true
    validates :username, presence: true, uniqueness: true
    validates :session_token, uniqueness: { scope: :username }

    attr_accessor :password
    before_validation :ensure_session_token

    def password=(password)
        @password = password
        self.password_digest = BCrypt::Password.create(password)
    end

    def is_password?(password)
        bcrypt_object = BCrypt::Password.new(self.password_digest)
        bcrypt_object.is_password?(password)
    end

    def self.find_by_credentials(username, password)
        user = User.find_by(username: username)

        if user && user.is_password?(password)
            return user
        else
            nil
        end
    end
    
    def reset_session_token!
        self.session_token = generate_unique_session_token
        self.save!
        return self.session_token
    end

    private

    def generate_unique_session_token
        token = SecureRandom::urlsafe_base64
        token = SecureRandom::urlsafe_base64 while User.exists(session_token: token)
        token
    end

    def ensure_session_token
        self.session_token ||= generate_unique_session_token
    end
end
