class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text, :type => String
  field :reply_to, :type => String

  validates_length_of :text, :in => 10..3000

  belongs_to :playlist
  belongs_to :user
end
