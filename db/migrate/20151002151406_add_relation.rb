class AddRelation < ActiveRecord::Migration
  def change
  	add_reference :jobs, :company
  end
end
