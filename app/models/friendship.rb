class Friendship < ApplicationRecord
  belongs_to :follower, class_name: "User", inverse_of: :following_friendships
  belongs_to :following, class_name: "User", inverse_of: :follower_friendships
end
