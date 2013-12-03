class RenameFromToInLinks < ActiveRecord::Migration
  def up
    rename_column :links, :from, :link_from
    rename_column :links, :to, :link_to
  end

  def down
  end
end
