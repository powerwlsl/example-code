class Company < ActiveRecord::Base
	has_many :jobs, dependent: :destroy
  has_many :posts, dependent: :destroy
	#checks if company name exists
	validates :name, uniqueness: true, presence: true
	before_create do
		self.description ||= ""
		self.link ||= ""
	end
  has_attached_file :logo, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/

  attr_reader :logo_remote_url

  def logo_remote_url=(url_value)
    if url_value.present?
      self.logo = URI.parse(url_value)
      # Assuming url_value is http://example.com/photos/face.png
      # avatar_file_name == "face.png"
      # avatar_content_type == "image/png"
      @logo_remote_url = url_value
    end
  end

end
