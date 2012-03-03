class User
  include Mongoid::Document
  field :vk_id, type: Inreger
  field :followers

  # has_many :playlists
end
