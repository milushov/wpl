class Follow
  include Mongoid::Document

  # В реализации гема "mongoid_follow" присутствует коллекция "follows",
  # которая служит для хранения связей между фолловером и тем кого фолловим.
  # Данный метод нужен чтобы найти все id'шники пользователей по плейлистам,
  # которые они слушают, понадобился для составления профайла пользователя. Такие дела.
  def self.getAllFollowersByPlaylistsIds(ids = [])
    followers_ids = self.any_in(followee_id: ids).to_a.map! { |f| f[:follower_id].to_s }
    followers = {}
    User.any_in(_id: followers_ids).to_a.each { |follower| followers[follower[:vk_id]] = follower[:_id].to_s }
    followers
  end
end