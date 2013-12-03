class Tangible < ActiveRecord::Base
  attr_accessible :table_id, :tangible_type, :subtype, :defaults, :local, :hardlink_to
  belongs_to :table
  has_many :hardlinks, :class_name => Tangible, :foreign_key => :hardlink_to
end
