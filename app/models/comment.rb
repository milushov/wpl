class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content, type: String
  field :reply_to, type: String

  validates_length_of :content, in: 10..3000

  belongs_to :playlist
  belongs_to :user

  class << self
    def getByIds ids
      any_in(_id: ids).includes(:user).to_a
    end
  end
end
