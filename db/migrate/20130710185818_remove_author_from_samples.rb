class RemoveAuthorFromSamples < ActiveRecord::Migration
  def up
    #remove_column :samples, :author_id
    remove_column :samples, :original_table_id
  end

  def down
  end
end
