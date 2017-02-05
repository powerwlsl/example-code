class AddUserEmploymentFields < ActiveRecord::Migration
  def change
  	remove_column :users, :synopsis, :string
	add_column :users, :synopsis, :text
	add_column :users, :year_in_industry, :text
	add_column :users, :education, :text
	add_column :users, :experience, :text 
	add_column :users, :skills, :text
  	
  end
end