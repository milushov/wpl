ENV["RAILS_ENV"] = "development"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'digest/md5'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  def get_user id
    User.any_of({screen_name: id}, {_id: id.to_i}).first
  end

  def get_playlist id
    Playlist.any_of({url: id}, {_id: id}).first
  end

  def set_cokies access_token, user_id, 
    app_id = 1111000
    app_secret = '1111000key'
    auth_key = Digest::MD5.hexdigest "#{app_id}_#{user_id}_#{app_secret}"
    @request.cookies[:access_token] = {value: access_token, domain: domain, expires: expires}
    @request.cookies[:user_id] = {value: user_id, domain: domain, expires: expires}
    @request.cookies[:auth_key] = {value: auth_key, domain: domain, expires: expires}
  end
end
