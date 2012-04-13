# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Playlist.delete_all and User.delete_all

p 'creating playlists...'
playlists = []
JSON.parse(File.open("#{Rails.root}/db/playlists.json").read.to_s).each do |playlist|
  playlists << Playlist.create!(playlist)
  p "create playlist - #{playlist["url"]}"
end

p '\n'

p 'creating users...'
users = File.open("#{Rails.root}/db/users.txt") do |users|
  users.read.each_line do |user|
    vk_id, screen_name, followee = user.split('|')
    new_user = User.create!(vk_id: vk_id, screen_name: screen_name)
    p "user #{new_user.screen_name} created"
  end
end

p '\n'

users = File.open("#{Rails.root}/db/users.txt") do |users|
  users.read.each_line do |user|
    vk_id, screen_name, followee = user.split('|')
    user_action = User.where({vk_id: vk_id}).first

    playlists.each do |playlist|
      if(rand(1..100).even?)
        user_action.follow( playlist )
        p "user #{user_action.screen_name} followed playlist #{playlist.url}"
      end
    end
    
    p '\n'

    followee.split(' ').each do |id|
      if(rand(1..100).even?)
        who_follow = User.where({vk_id: id}).first
        user_action.follow( who_follow )
        p "user #{user_action.screen_name} followed user #{who_follow.screen_name}"
      end
    end

    p '\n'
  end
end