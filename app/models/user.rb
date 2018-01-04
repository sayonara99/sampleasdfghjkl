class User < ApplicationRecord
# User class inherits from the ApplicationRecord class, which in turn inherits from the AciveRecord::Base class
# such that User model has all the functionality of the ActiveRecord::Base class.
# Active REcord takes data stored in a database table using rows and columns, which needs to be modified or retrieved
# by writing SQL statesments(if the database is SQL), and Active Record lets you interact with that data as though
# it was a normal Ruby object.

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
                                      

end
