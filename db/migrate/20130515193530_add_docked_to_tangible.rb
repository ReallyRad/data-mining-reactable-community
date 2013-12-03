class AddDockedToTangible < ActiveRecord::Migration
  def change
    add_column :tangibles, :docked, :int
  end
end
