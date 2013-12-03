class ChangeHardlinkToStringField < ActiveRecord::Migration
  def up
    remove_column :tangibles, :hardlink_to
    add_column :tangibles, :hardlink_to, :string
  end

  def down
    remove_column :tangibles, :hardlink_to
    add_column :tangibles, :hardlink_to, :integer
  end
end
