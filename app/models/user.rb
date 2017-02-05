class User < ActiveRecord::Base
  has_many :applies, dependent: :destroy
  has_many :watchlists, dependent: :destroy
  has_many :posts, foreign_key: :publisher_id
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # paperclip, aws, upload resume document
  has_attached_file :resume
  validates_attachment :resume, :content_type => { :content_type => %w(application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document) }
  # TODO look at the above validation, format is fucked up

  # removed password confirmation
  validates_confirmation_of :password
end
