class AuthUser < ActiveRecord::Base
  attr_accessible :uploads, :received_comments, :sent_comments
  has_many :tables, :foreign_key => :author
  has_many :comments

  def sent_comments
    Comment.find_all_by_author_id(id).count
  end

  def received_comments
    count = 0
    self.tables.each do |t|
    count +=  Comment.find_all_by_table_id(t.id).count
    end
    return count
  end

end
