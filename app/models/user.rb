class User
  include Mongoid::Document
  field :vk_id, type Integer
  field :followers, type: String
  
  has_many :playlists
end