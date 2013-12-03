class Link < ActiveRecord::Base
  belongs_to :table
  attr_accessible :link_from, :link_to, :table_id
end
