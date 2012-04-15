class Playlists.Models.User extends Backbone.Model
  defaults:
    vk_id: null

class Playlists.Collections.UsersCollection extends Backbone.Collection
  model: Playlists.Models.User
  url: 'api/users'
