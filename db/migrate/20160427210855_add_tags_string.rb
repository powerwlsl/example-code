class AddTagsString < ActiveRecord::Migration
  def change
    add_column :jobs, :tags_for_script, :string
  end
end
