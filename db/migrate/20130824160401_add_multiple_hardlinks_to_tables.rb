class AddMultipleHardlinksToTables < ActiveRecord::Migration
  def change
    add_column :tables, :multiple_hardlinks, :boolean
  end
end
