class Playlist
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Followee
  
  field :name, type: String
  field :image, type: String
  field :description, type: String
  field :tags, type: String

  field :url, type: String
  field :creator, type: Integer # право рекдактировать теги без голосования

  embeds_many :tracks
end
