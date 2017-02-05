class Post < ActiveRecord::Base
  belongs_to :company
  belongs_to :publisher, class_name: :User
  has_many :applies

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

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
end

# Delete the previous posts index in Elasticsearch
Post.__elasticsearch__.client.indices.delete index: Post.index_name rescue nil

# Create the new index with the new mapping
Post.__elasticsearch__.client.indices.create \
  index: Post.index_name,
  body: { settings: Post.settings.to_hash, mappings: Post.mappings.to_hash }

# Index all Post records from the DB to Elasticsearch
Post.import force: true
