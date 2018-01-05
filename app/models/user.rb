class User < ApplicationRecord
# User class inherits from the ApplicationRecord class, which in turn inherits from the AciveRecord::Base class
# such that User model has all the functionality of the ActiveRecord::Base class.
# Active REcord takes data stored in a database table using rows and columns, which needs to be modified or retrieved
# by writing SQL statesments(if the database is SQL), and Active Record lets you interact with that data as though
# it was a normal Ruby object.

  attr_accessor :remember_token

  before_save { email.downcase! }
  # the before_save callback is automatially called BEFORE the object is saved, which includes both
  # object creation and update
  # this modifies the email attribute directly.
  # or self.email = email.downcase
  # self refers to the current user
  # self keyword is optional on the righthand side in the User model
  # but it is not optional in an assignment on the lefthand side
  # or you can use before_save :downcase_email and add a downcase_email method in private.

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, 
                                    format: { with: VALID_EMAIL_REGEX },
                                    uniqueness: { case_sensitive: false }

  has_secure_password
  # this method adds
  # 1. the ability to save a securely hashed password_digest attribute to the database
  # 2. A pair of virtual attributes (password and password_confirmation), including presence validations upon 
  # object creation and a validation requiring that they match
  # 3. An authenticate method that returns the user when the password is correct (and returns false otherwise)
  # the corresponding model must have an attribute password_digest                        
  validates :password, presence: true, length: { minimum: 6, maximum: 72 }, 
                                       allow_nil: true
  
  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    # this uses the minimum cost parameter (MIN_COST) in tests and a normal cost parameter (cost) in production
    BCrypt::Password.create(string, cost: cost)
    # string is the string to be hashed and cost is the cost parameter that determines
    # the computational cost to calculate the hash
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user
  def forget
    update_attribute(:remember_digest, nil)
  end
  
end
