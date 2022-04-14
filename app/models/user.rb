class User < ApplicationRecord
  has_many :sleeps, dependent: :destroy

  has_many :follower_friendships, class_name: "Friendship",
    foreign_key: :following_id, inverse_of: :following, dependent: :destroy
  has_many :followers, through: :follower_friendships

  has_many :following_friendships, class_name: "Friendship",
    foreign_key: :follower_id, inverse_of: :follower, dependent: :destroy
  has_many :followings, through: :following_friendships

  def follow(another_user)
    return if followings.where(id: another_user.id).exists?
    followings << another_user
  end
end
