class AddTweakedToTangibles < ActiveRecord::Migration
  def change
    add_column :tangibles, :tweaked, :integer
  end
end
