class AddNonOriginalToTables < ActiveRecord::Migration
  def change
    add_column :tables, :non_original, :boolean
  end
end
