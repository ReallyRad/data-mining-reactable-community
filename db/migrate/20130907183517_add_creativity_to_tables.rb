class AddCreativityToTables < ActiveRecord::Migration
  def change
    add_column :tables, :creativity,:float
  end
end
