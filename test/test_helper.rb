ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  def get_user id
    User.any_of({screen_name: id}, {_id: id.to_i}).first
  end

  def get_playlist id
    Playlist.any_of({url: id}, {_id: id}).first
  end
end
