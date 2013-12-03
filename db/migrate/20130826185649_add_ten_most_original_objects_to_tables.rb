class AddTenMostOriginalObjectsToTables < ActiveRecord::Migration
  def change
    add_column :tables, :ten_original_objects, :boolean
  end
end
