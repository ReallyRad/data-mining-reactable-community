class AddTwentyOriginalConnectionsToTables < ActiveRecord::Migration
  def change
    add_column :tables, :twenty_original_connections, :boolean
  end
end
