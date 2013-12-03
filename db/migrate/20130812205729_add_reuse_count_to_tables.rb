class AddReuseCountToTables < ActiveRecord::Migration
  def change
    add_column :tables, :reuse_count, :integer
  end
end
