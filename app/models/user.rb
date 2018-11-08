require 'keytechKit'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  before_save { self.email = email.downcase }
  after_initialize :set_default_values, unless: :persisted?

  before_save :encrypt_values
  after_save :decrypt_values
  after_find :decrypt_values

  validates :name,  presence: false, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  def set_default_values
    self.keytech_url = ENV['KEYTECH_URL']
    self.keytech_username = ENV['KEYTECH_USERNAME']
    self.keytech_password = ENV['KEYTECH_PASSWORD']
  end

  def connection_valid?
    !keytechAPI.current_user.blank?
  rescue Exception => exc
    logger.error("Invalid keytech credentials or server not found #{exc.message}")
    false
  end

  def favorites
    Rails.cache.fetch("#{cache_key}/favorites", expires_in: 3.minute) do
      keytechAPI.current_user.favorites
    end
  end

  def queries
    Rails.cache.fetch("#{cache_key}/queries", expires_in: 3.minute) do
      keytechAPI.current_user.queries(withSystemQueries: 'all', ignoreTypes: 'attributes')
    end
  end

  # returns current keytech kit object
  def keytechAPI
    if @keytechAPI.nil?
      @keytechAPI = KeytechKit::KeytechKit.new(keytech_url, keytech_username, keytech_password)
    end
    @keytechAPI
  end

  def admin?
    email == ENV['ADMIN_MAIL']
  end

  def cache_key
    "#{keytech_username}@#{keytech_url}"
  end

  private

  def encrypt_values
    self.keytech_url = encrypt(keytech_url)
    self.keytech_username = encrypt(keytech_username)
    self.keytech_password = encrypt(keytech_password)
  end

  def decrypt_values
    self.keytech_url = decrypt(keytech_url)
    self.keytech_username = decrypt(keytech_username)
    self.keytech_password = decrypt(keytech_password)
  end

  # See https://medium.com/@MirMayne/a-simple-way-to-encrypt-and-decrypt-in-rails-5-9a514645d066
  def encrypt(value)
    value ||= ''
    len = ActiveSupport::MessageEncryptor.key_len
    password = ENV['CRYPTED_PASSWORD']

    key = ActiveSupport::KeyGenerator.new(password).generate_key(get_salt, len)
    crypt = ActiveSupport::MessageEncryptor.new(key)
    encrypted_data = crypt.encrypt_and_sign(value)
    encrypted_data
  rescue Exception => exc
    logger.error("Can not encrypt value #{exc.message}")
    ''
  end

  def decrypt(value)
    value ||= ''
    len = ActiveSupport::MessageEncryptor.key_len
    password = ENV['CRYPTED_PASSWORD']
    key = ActiveSupport::KeyGenerator.new(password).generate_key(get_salt, len)
    crypt = ActiveSupport::MessageEncryptor.new(key)
    decrypted_data = crypt.decrypt_and_verify(value)
    decrypted_data
  rescue Exception => exc
    logger.error("Can not decrpyt value #{exc.message}")
    ''
  end

  def get_salt
    if salt.blank?
      len = ActiveSupport::MessageEncryptor.key_len
      self.salt = Base64.encode64(SecureRandom.random_bytes(len))
    end
    Base64.decode64(salt)
  end
end
