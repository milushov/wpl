require 'test_helper'
Dir[Rails.root + 'app/models/**/*.rb'].each do |path|
  require path
end

class PlaylistsControllerTest < ActionController::TestCase
  setup do
    @playlist = get_playlist "test#{rand[1..9]}"
    @cookies = set_cokies '7f872125f4ceebb109013329910bdd04f1109810901338eeb456a9af265c57', 788157
  end

  test "should get popular" do
    get :popular, cookies: @cookies
    assert_response :success
    assert_not_nil assigns(:playlists)
    check_status

  end

  test "should get last" do
    get :last, cookies: @cookies
    assert_response :success
    assert_not_nil assigns(:playlists)
    check_status
  end

  test "should get last" do
    get :last, cookies: @cookies
    assert_response :success
    assert_not_nil assigns(:playlists)
    check_status
  end

  test "should get show" do
    get :last, id: @playlist.id, cookies: @cookies
    assert_response :success
    assert_not_nil assigns(:playlists)
    check_status
  end

  test "should get create" do
    new = @playlist.attributes
    new.url = new.id = nil
    post :create, new, @cookies
    assert_response :success
    assert_not_nil assigns(:playlists)
    check_status
  end

  test "should get follow" do
    get :follow, id: @playlist.id, cookies: @cookies
    assert_response :success
    assert_not_nil assigns(:playlists)
    check_status
  end

  test "should get unfollow" do
    get :unfollow, id: @playlist.id, cookies: @cookies
    assert_response :success
    assert_not_nil assigns(:playlists)
    check_status
  end

  test "should get unfollow" do
    get :last, id: @playlist.id, cookies: @cookies
    assert_response :success
    assert_not_nil assigns(:playlists)
    check_status
  end

  test "should get playlistsByTag" do
    get :playlistsByTag, id: "tag#{rand[1..4]}", cookies: @cookies
    assert_response :success
    assert_not_nil assigns(:playlists)
    check_status
  end

private
  def check_status
    resp = JSON.parse @response.body
    assert_equal resp.status, true
  end
end