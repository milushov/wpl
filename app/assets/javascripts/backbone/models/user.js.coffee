class Playlists.Models.User extends Backbone.Model

class Playlists.Collections.UsersCollection extends Backbone.Collection
  model: Playlists.Models.User
  url: 'api/users'
