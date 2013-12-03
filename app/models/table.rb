class Table < ActiveRecord::Base
   attr_accessible :auth_user_id, :samples, :defaults_ratio, :timestamp, :title, :originality, :days_since_upload, :reuse_count, :found_by_title, :found_by_zip_file, :zip_error, :found_by_title_and_author, :authors, :multiple_hardlinks, :twenty_original_connections, :creativity
   has_many :samples
   has_many :tangibles
   has_many :links
   belongs_to :auth_user, :foreign_key => :author
end
