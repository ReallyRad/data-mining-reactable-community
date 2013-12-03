class AddSentCommentsReceivedCommentsToUsers < ActiveRecord::Migration
  def change
    rename_table :auth_user, :auth_users
    add_column :auth_users, :sent_comments, :integer
    add_column :auth_users, :received_comments, :integer
  end
end
