class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongo::Voter

  include Mongoid::Followee
  include Mongoid::Follower

  field :vk_id, type: Integer
  field :screen_name, type: String
end