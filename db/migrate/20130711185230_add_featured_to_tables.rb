class AddFeaturedToTables < ActiveRecord::Migration
  def change
    add_column :tables, :featured, :boolean
  end
end
