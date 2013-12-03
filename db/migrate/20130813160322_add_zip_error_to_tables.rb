class AddZipErrorToTables < ActiveRecord::Migration
  def change
    add_column :tables, :zip_error, :boolean
    add_column :tables, :found_by_title_and_author, :boolean
  end
end
