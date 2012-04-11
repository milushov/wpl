# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

playlists = JSON.parse File.open("#{Rails.root}/db/playlists.json").read.to_s

Playlist.delete_all and User.delete_all

created_playlists = []

p 'creating playlists...'
playlists.each do |playlist|
  created_playlists << Playlist.create!(playlist)
  p "create playlist - #{playlist["name"]}"
end

p 'creating users...'
users = File.open("#{Rails.root}/db/users.txt") do |users|
  users.read.each_line do |user|
    vk_id, followee = user.split('|')
    new_user = User.create!(vk_id: vk_id)
    p "user #{new_user.id.to_s[-3,3]} created"
  end
end

users = File.open("#{Rails.root}/db/users.txt") do |users|
  users.read.each_line do |user|
    vk_id, followee = user.split('|')
    user_action = User.where({vk_id: vk_id}).first

    created_playlists.each do |playlist|
      if (rand(1..100).even?)
        user_action.follow( playlist )
        p "user #{user_action.id.to_s[-3,3]} followed playlist #{playlist.id.to_s[-3,3]}"
      end
    end
    
    followee.split(' ').each do |id|
      if (rand(1..100).even?)
        who_follow = User.where({vk_id: id}).first
        user_action.follow( who_follow )
        p "user #{user_action.id.to_s[-3,3]} followed user #{who_follow.id.to_s[-3,3]}"
      end
    end
  end
end