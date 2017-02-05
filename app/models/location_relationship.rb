class LocationRelationship < ActiveRecord::Base
	belongs_to :jobs
	belongs_to :locations
end
