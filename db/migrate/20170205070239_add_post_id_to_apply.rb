class AddPostIdToApply < ActiveRecord::Migration
  def change
    add_column :applies, :post_id, :integer
  end
end
