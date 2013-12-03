class AddTimeSinceUplodToTables < ActiveRecord::Migration
  def change
    add_column :tables, :days_since_upload, :integer
  end
end
