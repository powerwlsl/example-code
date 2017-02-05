class CreateWatchlists < ActiveRecord::Migration
  def change
    create_table :watchlists do |t|
      	t.timestamps null: false
      	t.references :user, index: true, foreign_key: true
      t.references :job, index: true, foreign_key: true

    end
  end
end
