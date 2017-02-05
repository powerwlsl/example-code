class AddJobElements < ActiveRecord::Migration
  def change
  	add_column :jobs, :source, :string
  	add_column :jobs, :location, :string
  end
end
