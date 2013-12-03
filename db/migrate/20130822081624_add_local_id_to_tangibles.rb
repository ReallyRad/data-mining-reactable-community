class AddLocalIdToTangibles < ActiveRecord::Migration
  def change
    add_column :tangibles, :local, :integer
  end
end
