class Sample < ActiveRecord::Base
  attr_accessible :filename, :artist_id, :table_id, :md5_hash, :id, :zip_timestamp, :original_table_id
  belongs_to :table
  belongs_to :original_table, :class_name => 'Table'
end
