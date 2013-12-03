class AddDefaultsRatioToTable < ActiveRecord::Migration
  def change
    add_column :tables, :defaults_ratio, :float
  end
end
