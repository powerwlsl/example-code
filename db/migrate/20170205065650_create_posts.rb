class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.text :description
      t.references :company, index: true, foreign_key: true
      t.references :publisher, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
