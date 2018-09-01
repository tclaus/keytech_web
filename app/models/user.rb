
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

 before_save { self.email = email.downcase }
 before_save :default_values
 validates :name,  presence: false, length: { maximum: 50 }

 VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
 validates :email, presence: true, length: { maximum: 255 },
                   format: { with: VALID_EMAIL_REGEX },
                   uniqueness: { case_sensitive: false }


   def default_values
     # TODO: Crypt username / password
     self.keytech_url ||= 'https://demo.keytech.de'# TODO: Use Environment
     self.keytech_username ||= 'jgrant'# TODO: Use Environment
     self.keytech_password ||= ''# TODO: Use Environment
   end

   # returns current keytech kit object
   def keytechKit
      KeytechKit::Keytech_Kit.new(self.keytech_url, self.keytech_username, keytech_password)
   end

   def favorites
     keytechKit.currentUser.favorites
   end

   def queries
     keytechKit.currentUser.queries
   end

end
