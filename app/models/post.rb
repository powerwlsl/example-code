class Post < ActiveRecord::Base
  belongs_to :company
  belongs_to :publisher
end