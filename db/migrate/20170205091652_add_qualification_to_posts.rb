class AddQualificationToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :qualification, :text
  end
end
