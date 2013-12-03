class AddOsToTable < ActiveRecord::Migration
  def change
    add_column :tables, :os, :string
  end
end
