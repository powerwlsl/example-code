require 'elasticsearch/model'

class Job < ActiveRecord::Base
	belongs_to :company
	has_many :applies, dependent: :destroy

	validates :title, presence: true
	validates_uniqueness_of :title, scope: :company_id

	has_many :taggings, dependent: :destroy
	has_many :tags, :through => :taggings
	has_many :location_relationship

	include Elasticsearch::Model
	include Elasticsearch::Model::Callbacks

	def tag_list
		tags.join ", "
	end

	def tag_list=(tags_string)
	  tag_names = tags_string.split(",").collect{|s| s.strip}.uniq
	  new_or_found_tags = tag_names.collect { |name| Tag.find_or_create_by(name: name) }
	  self.tags = new_or_found_tags
	end

	def self.search(query)
	  __elasticsearch__.search(
		{
			from: 0, size: 500,
			query: {
				function_score:{
					functions: [{
						gauss: {
							created_at: {
								origin: 'now',
								scale: '3d',
								offset: '2d',
								decay: 0.95
							}
						}
					}],
					query: {
						multi_match: {
							query: query,
							fields: ['title^3', 'description', 'qualification', 'location^3']
						}
					}
				}
			}
		}
	  )
	end

	settings index: { number_of_shards: 1 } do
	  mappings dynamic: 'false' do
	    indexes :title, analyzer: 'english'
	    indexes :description, analyzer: 'english'
			indexes :qualification, analyzer: 'english'
			indexes :location, analyzer: 'english'
			indexes :created_at, type: 'date'
		end
	end
end

# Delete the previous jobs index in Elasticsearch
Job.__elasticsearch__.client.indices.delete index: Job.index_name rescue nil

# Create the new index with the new mapping
Job.__elasticsearch__.client.indices.create \
  index: Job.index_name,
  body: { settings: Job.settings.to_hash, mappings: Job.mappings.to_hash }

# Index all job records from the DB to Elasticsearch
Job.import force: true
