class RenameDescendencyToSampleInfluence < ActiveRecord::Migration

  def change
    rename_column :tables, :descendency, :sample_influence
  end

end
