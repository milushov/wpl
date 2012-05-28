class User
  SHOW_FIELDS = %w{ id screen_name first_name last_name photo photo_big sex }

  include Mongoid::Document
  include Mongoid::Timestamps

  include Mongoid::Followee
  include Mongoid::Follower

  field :id, type: Integer
  field :screen_name, type: String

  field :first_name, type: String, default: ''
  field :last_name, type: String, default: ''
  field :sex, type: Integer, default: 0 # 2-man 1-woman 0-unknown
  
  field :photo, type: String
  field :photo_big, type: String

  field :activity, type: Integer, default: 0
  field :visits_count, type: Integer, default: 0
  field :last_visit, type: DateTime, default: Time.now

  field :ban, type: Boolean, default: false
  field :unban_date, type: DateTime

  field :app_friends, type: Array, default: []

  # scope :find2, ->(id) { any_of({screen_name: id}, {_id: id}).first }

  index :screen_name, unique: true

  has_many :comments

  def me? user_id
    self.id == user_id.to_i
  end

  # returns only those properties that can be given to the client
  def show param = {}
    show_fields = SHOW_FIELDS.map(&:to_sym)
    show_fields -= param[:without].map(&:to_sym) if param[:without]
    obj = {}
    show_fields.each { |f| obj[f] = self[f == :id ? :_id : f] }
    obj[:id] ||= self[:id] # if @self contain properly :id
    obj
  end

  class << self
    def getByIds ids
      playlists_followers = {}
      any_in(_id: ids).to_a.each do |follower|
        playlists_followers[follower[:_id]] = follower.show
      end
      playlists_followers
    end
  end
end

class Hash
  def show param = {}
    show_fields = User::SHOW_FIELDS.map(&:to_sym)
    show_fields -= param[:without].map(&:to_sym) if param[:without]
    obj = {}
    show_fields.each { |f| obj[f] = self[f == :id ? :_id : f] }
    obj[:id] ||= self[:id] # if @self contain properly :id
    obj
  end
end