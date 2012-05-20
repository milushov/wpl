class User
  include Mongoid::Document
  include Mongoid::Timestamps

  include Mongoid::Followee
  include Mongoid::Follower

  field :id, type: Integer
  field :screen_name, type: String

  field :first_name, type: String, default: ''
  field :last_name, type: String, default: ''
  
  field :photo, type: String
  field :photo_big, type: String

  field :activity, type: Integer, default: 0
  field :visits_count, type: Integer, default: 0
  field :last_visit, type: DateTime, default: Time.now

  field :ban, type: Boolean, default: false
  field :unban_date, type: DateTime

  field :app_friends, type: Array, default: []

  # scope :find2, ->(id) { any_of({screen_name: id}, {_id: id}).first }

  def me? user_id
    self.id == user_id.to_i
  end
end