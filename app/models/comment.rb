class Comment < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :auth_user
  #belongs_to :table, :foreign_key => reactable_table_id


end
