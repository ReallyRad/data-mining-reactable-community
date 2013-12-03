class AddOriginalityToTables < ActiveRecord::Migration
  def change
    add_column :tables, :originality, :float
  end
end
