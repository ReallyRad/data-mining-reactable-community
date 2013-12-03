class AddUploadsCountToUsers < ActiveRecord::Migration
  def change
    add_column :auth_user, :uploads, :int
  end
end
