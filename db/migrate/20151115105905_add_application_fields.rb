class AddApplicationFields < ActiveRecord::Migration
  def change
  	add_column :applies, :synopsis, :text
  	add_column :applies, :education, :text
  	add_column :applies, :experience, :text
  	add_column :applies, :skills, :text
  end
end
