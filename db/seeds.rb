# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require "#{Rails.root}/app/models/mongoid-simple-tags.rb"

Playlist.delete_all and User.delete_all and Follow.delete_all

artists_photos = %w{ http://userserve-ak.last.fm/serve/34s/61520993.png http://userserve-ak.last.fm/serve/34s/71349074.png http://userserve-ak.last.fm/serve/34s/70383082.png http://userserve-ak.last.fm/serve/34s/50183455.png http://userserve-ak.last.fm/serve/34s/74977662.png http://userserve-ak.last.fm/serve/34s/57494593.png }

p 'creating playlists...'
playlists = []
JSON.parse(File.open("#{Rails.root}/db/playlists.json").read.to_s).each do |playlist|
  playlist['tracks'].each do |t|
    t['artist_photo'] = artists_photos[rand 0..artists_photos.size-1]
    t['duration'] = rand(70..360)
  end
  pl = Playlist.new(playlist)
  pl.tag_list = playlist['tags']
  pl.save
  playlists << pl
  p "create playlist - #{playlist["url"]} with tags: #{pl.tags}"
end

p ''

p 'creating users...'
users = []
JSON.parse(File.open("#{Rails.root}/db/users.json").read.to_s)['response'].each do |user|
  user['id'] = user['uid']
  user.delete 'uid'
  new_user = User.create! user
  users << new_user
  p "user #{new_user.screen_name} created"
end

p ''

users.each do |user|
  playlists.each do |playlist|
    if rand(1..2).even? or rand(1..2).even?
      user.follow(playlist)
      p "user #{user.screen_name} followed playlist #{playlist.url}"
    end
  end
  
  users.each do |followee|
    if rand(1..2).even? or rand(1..2).even?
      user.follow(followee) if user.id != followee.id
      p "user #{user.screen_name} followed user #{followee.screen_name}"
    end
  end
end