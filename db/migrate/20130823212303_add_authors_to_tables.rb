class AddAuthorsToTables < ActiveRecord::Migration
  def change
    add_column :tables, :authors, :integer
  end
end
