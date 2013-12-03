class RenameTypeToTangibleType < ActiveRecord::Migration
  def up
    rename_column :tangibles, :type, :tangible_type
  end

  def down
    rename_column :tangibles, :tangible_type, :type
  end
end
