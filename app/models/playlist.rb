class Playlist
  include Mongoid::Document
  
  field :name, :type => String
  field :description, :type => String
  field :tags, :type => String

  embeds_many :tracks
end
