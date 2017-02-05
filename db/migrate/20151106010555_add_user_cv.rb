class AddUserCv < ActiveRecord::Migration
  def change
  	add_column :users, :first_name, :string
  	add_column :users, :last_name, :string
  	add_column :users, :phone_number, :string
  	add_column :users, :mobile_number, :string
  	add_column :users, :city, :string
  	add_column :users, :country, :string
  	add_column :users, :postal_code, :string
  	add_column :users, :synopsis, :string
  	remove_column :users, :name, :string
  end
end
