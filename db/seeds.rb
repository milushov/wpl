require "#{Rails.root}/app/models/mongoid-simple-tags.rb"
# require 'pry'

Playlist.delete_all and User.delete_all and Follow.delete_all and Comment.delete_all


p 'creating users...'

users = []
users_ids = []
JSON.parse(File.open("#{Rails.root}/db/users.json").read.to_s)['response'].each do |user|
  user['id'] = user['uid']
  users_ids << user['id'].to_i
  user.delete 'uid'
  new_user = User.create! user
  users << new_user
  p "user #{new_user.screen_name} created"
end

artists_photos = %w{ http://userserve-ak.last.fm/serve/34s/61520993.png http://userserve-ak.last.fm/serve/34s/71349074.png http://userserve-ak.last.fm/serve/34s/70383082.png http://userserve-ak.last.fm/serve/34s/50183455.png http://userserve-ak.last.fm/serve/34s/74977662.png http://userserve-ak.last.fm/serve/34s/57494593.png }
text = File.open("#{Rails.root}/db/Steve_Jobs.txt").read.to_s.split('. ')

p 'creating playlists...'

playlists = []

JSON.parse(File.open("#{Rails.root}/db/playlists.json").read.to_s).each do |playlist|
  playlist['tracks'].each do |t|
    t['artist_photo'] = artists_photos[rand 0..artists_photos.size-1]
    t['duration'] = rand(70..360)
    t['lovers'] = []
    t['haters'] = []

    users_ids.each do |id|
      if rand(0..1).even?
        t['lovers'] << id
      else
        t['haters'] << id
      end
    end 

    t['lovers_count'] = t['lovers'].count
    t['haters_count'] = t['haters'].count
  end
  
  pl = Playlist.new(playlist)
  pl.tag_list = playlist['tags']
  pl.save
  playlists << pl
  p "   create playlist - #{playlist["url"]} with tags: #{pl.tags}"
end


p 'creating social network: users follow each other and users follow playlists...'

users.each do |user|
  playlists.each do |playlist|
    if rand(1..2).even? or rand(1..2).even?
      user.follow(playlist)

      comment_text = ''
      rand(1..10).times { comment_text += text[rand(0...text.size)]+'.' }
      
      comment = Comment.new content: comment_text
      comment.created_at = Time.now + rand(-10..10).months + rand(-10..10).days + rand(-10..10).hour + rand(-10..10).minutes
      comment.user = user

      playlist.comments << comment

      # p "user #{user.screen_name} followed playlist #{playlist.url}"
    end
  end

  users.each do |followee|
    if rand(1..2).even? or rand(1..2).even?
      user.follow(followee) if user.id != followee.id
      # p "user #{user.screen_name} followed user #{followee.screen_name}"
    end
  end
end

Comment.all.each do |comment|
  comment.created_at = Time.now - rand(1..10).months + rand(-10..10).days + rand(-10..10).hour + rand(-10..10).minutes
  comment.save
end