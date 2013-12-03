class RemoveDockedFromTangibles < ActiveRecord::Migration
  def up
    remove_column :tangibles, :docked
  end

  def down
    add_column :tangibles, :docked, :integer
  end
end
