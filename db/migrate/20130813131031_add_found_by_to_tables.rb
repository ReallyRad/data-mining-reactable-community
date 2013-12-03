class AddFoundByToTables < ActiveRecord::Migration
  def change
    add_column :tables, :found_by_zip_file, :boolean
    add_column :tables, :found_by_title, :boolean
  end
end
