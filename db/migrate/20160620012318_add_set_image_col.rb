class AddSetImageCol < ActiveRecord::Migration
  def change
    add_column :companies, :set_image, :boolean, default: false
  end
end
