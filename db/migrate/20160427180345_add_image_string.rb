class AddImageString < ActiveRecord::Migration
  def change
    add_column :companies, :logo_image_url_for_script, :string
  end
end
