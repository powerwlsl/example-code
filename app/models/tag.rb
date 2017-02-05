class Tag < ActiveRecord::Base
	has_many :taggings, dependent: :destroy
	has_many :jobs, through: :taggings
	validates :name, uniqueness: { case_sensitive: false }

	def to_s
		name
	end
end
