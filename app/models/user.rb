class User < ApplicationRecord
  # this is quivalent to writing just:
  # microposts
# User class inherits from the ApplicationRecord class, which in turn inherits from the AciveRecord::Base class
# such that User model has all the functionality of the ActiveRecord::Base class.
# Active REcord takes data stored in a database table using rows and columns, which needs to be modified or retrieved
# by writing SQL statesments(if the database is SQL), and Active Record lets you interact with that data as though
# it was a normal Ruby object.
  has_many :microposts, dependent: :destroy
  # dependent: :destroy arranges for the dependent microposts to be destroyed when the user itself is destroyed
  has_many :active_relationships, class_name: "Relationship", 
                                  foreign_key: "follower_id", 
                                  dependent: :destroy
  # we don't use :relationships directly because there are passive&active relationships
  # but we can tell Rails the model class name to look for using class_name: "Relationship"
  has_many :following, through: :active_relationships, source: :followed
  # a user has many following through relationships
  # by default, has_many through: association looks for a foreign key corresponding to the singular version of the association
  # ex. has_many :followeds, through: :active_relationships will look for a foreign key :followed
  # but this is awkward, so we change to :following, with source: :followed
  # this leads to combination of Active Record and array-like behaviour => can use include? method and find method
  # and we can add and delete elements i.e. << user or .delete(user)
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                   dependent: :destroy
  has_many :followers, through: :passive_relationships # , source: :follower

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

  def feed
    # Micropost.where("user_id = ?", id)
    # the ? ensures that the id is properly escaped before being included in the underlying SQL query
    # this picks out all the microposts with user id corresponding to the current user

    # we need to select all the microposts from the microposts table, with ids corresponding to the users being followed
    # by a given user; this can be written schematically as:
    # SELECT * FROM microposts
    # WHERE user_id IN (<list of ids>) OR user_id = <user id>
    # (SQL supports an IN key word that allows us to test for set inclusion)
    # we need an array of ids corresponding to the users being followed.
    # one way to do this is using Ruby's map method,
    # [1, 2, 3, 4].map { |i| i.to_s } => ["1", "2", "3", "4"]
    # or [1, 2, 3, 4].map(&:to_s)
    # constructing the necessary array of followed user ids
    # User.first.following.map(&:id) => [3, 4, 5, 6, ..., 50]
    # or User.first.following_ids => [               ]
    # but we can accomplish this with the below

    # Micropost.where("user_id IN (:following_ids) OR user_id = :user_id", following_ids: following_ids, user_id: id)
    # we can replace following_ids  with  following_ids = "SELECT followed_id FROM relationships
    #                                                      WHERE follower_id = :user_id"
    # the entire select for user 1 would look like:
    # SELECT * FROM microposts
    # WHERE user_id IN (SELECT followed_id FROM relationships
    #                   WHERE follower_id = 1)
    #       OR user_id = 1
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end

  # Follows a user.
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
    # or
    # following << other_user
  end

  # Unfollows a user.
  def unfollow(other_user)
    following.delete(other_user)
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end
  

  private
  
end
