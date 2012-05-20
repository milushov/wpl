# не понимаю, почему рельсы перестали подгужить этот файл
require 'mongoid-simple-tags'

class Playlist
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Followee
  include Mongoid::Document::Taggable
  
  field :name, type: String
  field :image, type: String
  field :description, type: String

  field :url, type: String
  field :creator, type: Integer # право рекдактировать теги без голосования

  embeds_many :tracks

  # scope :find2, ->(id_or_url) { self.any_of({url: id_or_url}, {_id: id_or_url}).first }
end