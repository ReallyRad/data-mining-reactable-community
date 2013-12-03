class AddHardlinkToTangibles < ActiveRecord::Migration
  def change
    add_column :tangibles, :hardlink_to, :integer
  end
end
