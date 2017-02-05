class Post < ActiveRecord::Base
  belongs_to :company
  belongs_to :publisher, class_name: :User
  has_many :applies
end
