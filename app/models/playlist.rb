# не понимаю, почему рельсы перестали подгужить этот файл
require 'mongoid-simple-tags'

class Playlist
  MAX_LENGTH = 100
  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Followee
  include Mongoid::Document::Taggable
  include Mongoid::Search
  
  field :name, type: String
  field :image, type: String
  field :image_small, type: String, default: nil
  field :description, type: String

  field :url, type: String
  field :creator, type: Integer # право рекдактировать теги без голосования

  embeds_many :tracks
  has_many :comments

  index :name
  index :description
  index :url, unique: true

  validates_length_of :name, :in => 5..MAX_LENGTH
  validates_length_of :image, :in => 5..30
  validates_length_of :url, :in => 5..MAX_LENGTH
  
  validates_length_of :description, :in => 5..1000

  search_in :name, :description, :url #tracks: :artist, tracks: :title, match: :all

  # scope :find2, ->(id_or_url) { self.any_of({url: id_or_url}, {_id: id_or_url}).first }

  class << self
    def find2 id
      any_of({url: id}, {_id: id}).first
    end
  end
end