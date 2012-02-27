class Track
  include Mongoid::Document

  field :artist, :type => String
  field :title, :type => String
  field :duration, :type => Integer
  field :audio_id, :type => String

  embedded_in :playlist
end
