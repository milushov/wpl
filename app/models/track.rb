class Track
  include Mongoid::Document
  include Mongoid::Timestamps

  field :artist, type: String
  field :title, type: String
  field :duration, type: Integer
  field :audio_id, type: String
  field :artist_photo, type: String

  field :lovers, type: Array, default: []
  field :lovers_count, type: Integer, default: 0

  field :haters, type: Array, default: []
  field :haters_count, type: Integer, default: 0

  embedded_in :playlist
end
