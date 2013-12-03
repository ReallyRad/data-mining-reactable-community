class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :from
      t.string :to
      t.references :table
      t.timestamps
    end
    add_index :links, :table_id
  end
end
