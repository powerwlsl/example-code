class CreateLocationRelationships < ActiveRecord::Migration
  def change
    create_table :location_relationships do |t|
      t.references :job, index: true, foreign_key: true
      t.references :location, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
