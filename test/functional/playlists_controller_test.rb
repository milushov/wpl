require 'test_helper'
Dir[Rails.root + 'app/models/**/*.rb'].each do |path|
  require path
end

class PlaylistsControllerTest < ActionController::TestCase
  setup do
    @playlist = Playlist.first
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:playlists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create playlist" do
    assert_difference('Playlist.count') do
      post :create, playlist: @playlist.attributes
    end

    assert_redirected_to playlist_path(assigns(:playlist))
  end

  test "should show playlist" do
    get :show, id: @playlist
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @playlist
    assert_response :success
  end

  test "should update playlist" do
    put :update, id: @playlist, playlist: @playlist.attributes
    assert_redirected_to playlist_path(assigns(:playlist))
  end

  test "should destroy playlist" do
    assert_difference('Playlist.count', -1) do
      delete :destroy, id: @playlist
    end

    assert_redirected_to playlists_path
  end

  # def setup
  #   set_cokies '7f872125f4ceebb109013329910bdd04f1109810901338eeb456a9af265c57', 124281120
  # end

end