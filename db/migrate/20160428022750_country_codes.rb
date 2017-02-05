class CountryCodes < ActiveRecord::Migration
  def change
    add_column :jobs, :country_code, :string
    add_column :jobs, :continent, :string
  end
end
