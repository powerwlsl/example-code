class AddIdsToApplies < ActiveRecord::Migration
  def change
    add_column :applies, :user_id, :integer
    add_column :applies, :job_id, :integer
  end
end
