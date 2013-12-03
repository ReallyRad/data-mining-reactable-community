class CreateTangibles < ActiveRecord::Migration
  def change
    create_table :tangibles do |t|
      t.string :type
      t.string :subtype
      t.references :table
      t.timestamps
    end
  end
end
