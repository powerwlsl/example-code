class AddColumnApply < ActiveRecord::Migration
  def change
  	add_column :applies, :cover_letter, :text
  	add_column :applies, :job_objective, :text
  end
end
