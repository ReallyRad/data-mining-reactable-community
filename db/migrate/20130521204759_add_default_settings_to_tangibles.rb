class AddDefaultSettingsToTangibles < ActiveRecord::Migration
  def change
    add_column :tangibles, :defaults, :integer
  end
end
