class RenameAscendencyToAscent < ActiveRecord::Migration
  def up
    rename_column :tables, :ascendency, :ascent
  end

  def down
  end
end
