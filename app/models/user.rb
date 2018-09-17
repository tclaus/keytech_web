require 'keytechKit'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

 before_save { self.email = email.downcase }
 before_create :default_values

 before_save :encryptValues
 after_save :decryptValues
 after_initialize :decryptValues

 validates :name,  presence: false, length: { maximum: 50 }

 VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
 validates :email, presence: true, length: { maximum: 255 },
                   format: { with: VALID_EMAIL_REGEX },
                   uniqueness: { case_sensitive: false }


   def default_values
     self.keytech_url ||= 'https://demo.keytech.de' # TODO: Use Environment
     self.keytech_username ||= 'jgrant' # TODO: Use Environment
     self.keytech_password ||= '' # TODO: Use Environment
   end

   def hasValidConnection
     begin
       return !keytechAPI.currentUser.blank?
     rescue Exception => exc
       logger.error("Invalid keytech credentials or server not found #{exc.message}")
       return false
     end
   end

   def favorites
     Rails.cache.fetch("#{key}", expires_in: 3.minute) do
       keytechAPI.currentUser.favorites
     end

   end

   def queries
     Rails.cache.fetch("#{key}", expires_in: 3.minute) do
       keytechAPI.currentUser.queries
     end
   end

   # returns current keytech kit object
   def keytechAPI
     if @keytechAPI == nil
       @keytechAPI = KeytechKit::Keytech_Kit.new(keytech_url, keytech_username, keytech_password)
     end
     return @keytechAPI
   end

private
    def key
      "#{keytech_username}@#{keytech_url}"
    end

    def encryptValues
      self.keytech_url = encrypt(self.keytech_url)
      self.keytech_username = encrypt(self.keytech_username)
      self.keytech_password = encrypt(self.keytech_password)
    end

    def decryptValues
      self.keytech_url = decrypt(self.keytech_url)
      self.keytech_username = decrypt(self.keytech_username)
      self.keytech_password = decrypt(self.keytech_password)
    end

   # See https://medium.com/@MirMayne/a-simple-way-to-encrypt-and-decrypt-in-rails-5-9a514645d066
   def encrypt(value)
     begin
       value = value || ""
       len = ActiveSupport::MessageEncryptor.key_len
       password = ENV['CRYPTED_PASSWORD']

       key = ActiveSupport::KeyGenerator.new(password).generate_key(getSalt,len)
       crypt = ActiveSupport::MessageEncryptor.new(key)
       encrypted_data = crypt.encrypt_and_sign(value)
       return encrypted_data
     rescue Exception => exc
       logger.error("Can not encrypt value #{exc.message}")
       return ""
     end
   end

   def decrypt(value)
     begin
       value = value || ""
       len = ActiveSupport::MessageEncryptor.key_len
       password = ENV['CRYPTED_PASSWORD']
       key = ActiveSupport::KeyGenerator.new(password).generate_key(getSalt,len)
       crypt = ActiveSupport::MessageEncryptor.new(key)
       decrypted_data = crypt.decrypt_and_verify(value)
       return decrypted_data
     rescue Exception => exc
       logger.error("Can not decrpyt value #{exc.message}")
       return ""
     end
   end

   def getSalt
     if self.salt.blank?
       puts ".. salt is blank"
       len = ActiveSupport::MessageEncryptor.key_len
       self.salt = Base64.encode64(SecureRandom.random_bytes(len))
     end
     Base64.decode64(self.salt)
   end


end
