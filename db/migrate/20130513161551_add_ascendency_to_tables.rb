class AddAscendencyToTables < ActiveRecord::Migration
  def change
    add_column :tables, :ascendency, :int
  end
end
