class Track
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongo::Voteable

  field :artist, type: String
  field :title, type: String
  field :duration, type: Integer
  field :audio_id, type: String

  embedded_in :playlist

  voteable self, :up => +1, :down => -1, :index => true
end
