class AddDescendancyToTable < ActiveRecord::Migration
  #alter table tables drop foreign key `events_ibfk_1` ;

def change
    rename_table :reactable_table, :tables
    add_column :tables, :descendency, :integer
  end
end
