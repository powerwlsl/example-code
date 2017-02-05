# for scraping
require 'rest-client' 	#http requests
require 'sanitize'		#html sanitization
require 'htmlentities' 	#html decoding

# for inserting to database
require 'active_record'
require 'activerecord-import'
require 'pg'
require 'json'

require 'rails'
require 'paperclip'
require 'aws-sdk'

# required classes to build objects for insertion
# cannot use require model file since there is executable elasticsearch code

class Job < ActiveRecord::Base
	belongs_to :company
	has_many :applies, dependent: :destroy

	validates :title, presence: true
	validates_uniqueness_of :title, scope: :company_id

	has_many :taggings, dependent: :destroy
	has_many :tags, :through => :taggings
	has_many :location_relationship

	def tag_list
		tags.join ", "
	end

	def tag_list=(tags_string)
	  tag_names = tags_string.split(",").collect{|s| s.strip}.uniq
	  new_or_found_tags = tag_names.collect { |name| Tag.find_or_create_by(name: name) }
	  self.tags = new_or_found_tags
	end
end


class Company < ActiveRecord::Base
	has_many :jobs, dependent: :destroy
	#checks if company name exists
	validates :name, uniqueness: true, presence: true
	before_create do
		self.description ||= ""
		self.link ||= ""
	end
  # has_attached_file :logo, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  # validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/

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
