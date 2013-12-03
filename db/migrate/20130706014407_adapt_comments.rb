class AdaptComments < ActiveRecord::Migration
  def up
  rename_table :comment, :comments
  #  rename_column :comments, :author, :auth_user_id
  end

  def down
  end
end
