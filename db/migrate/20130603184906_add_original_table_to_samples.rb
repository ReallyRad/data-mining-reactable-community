class AddOriginalTableToSamples < ActiveRecord::Migration
  def change
    add_column :samples, :original_table_id, :integer
  end
end
