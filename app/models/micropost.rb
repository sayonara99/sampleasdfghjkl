class Micropost < ApplicationRecord
  belongs_to :user
  # this works because the microposts table has a user_id attribute to identify the user
  # an id used in this manner to connect the two database tables is known as a foreign key, and when the foreign
  # key for a User model object is user_id, Rails infers the association automatically: foreign key in the form
  # <class>_id
  default_scope -> { order(created_at: :desc) }
  #                  order('created_at DESC') works too, this is raw SQL (DESC for descending)
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate :picture_size


  private

    # Validates the size of an uploaded picture.
    def picture_size
      if picture.size > 5.megabytes
      	errors.add(:picture, "should be less than 5MB")
      end
    end
end
