class User < ApplicationRecord
  has_many :sleeps, dependent: :destroy

  has_many :follower_friendships, class_name: "Friendship",
    foreign_key: :following_id, inverse_of: :following, dependent: :destroy
  has_many :followers, through: :follower_friendships

  has_many :following_friendships, class_name: "Friendship",
    foreign_key: :follower_id, inverse_of: :follower, dependent: :destroy
  has_many :followings, through: :following_friendships

  class << self
    def friends_of(user)
      following_ids = user.following_friendships.pluck(:following_id)
      follower_ids = user.follower_friendships.pluck(:follower_id)
      where(id: follower_ids + following_ids)
    end
  end

  def follow(another_user)
    return if followings.exists?(id: another_user.id)
    followings << another_user
  end

  def unfollow(another_user)
    followings.delete(another_user)
  end
end
