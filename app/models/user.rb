class User
	include Mongoid::Document
	include Mongoid::Timestamps

	include Mongoid::Followee
	include Mongoid::Follower

	field :vk_id, type: Integer
end