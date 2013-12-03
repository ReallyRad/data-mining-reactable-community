class RenameAuthorToAuthUser < ActiveRecord::Migration
  #before: alter table auth_user rename to auth_users;
  def up
      #rename_table :reactable_table, :tables
  end

  def down
  end
end
