require "rails_helper"

RSpec.describe User, type: :model do
  let(:user) { described_class.create!(name: "Test user") }
  let(:second_user) { described_class.create!(name: "Second user") }
  let(:third_user) { described_class.create!(name: "Third user") }

  it "deletes associated sleeps when deleted" do
    sleeps_count = Sleep.count
    user.sleeps.create!
    user.destroy!
    expect(Sleep.count).to eq(sleeps_count)
  end

  describe "follows another user" do
    before do
      user.follow(second_user)
    end

    it "becomes a follower" do
      expect(second_user.followers).to include(user)
    end

    it "cannot follow twice" do
      user.follow(second_user)
      expect(user.followings.where(id: second_user.id).count).to eq(1)
    end

    it "sets the other user as a following" do
      expect(user.followings).to include(second_user)
    end

    it "delete following friendship when following user deleted" do
      friendships_count = user.following_friendships.count
      second_user.destroy!
      expect(user.following_friendships.count).to eq(friendships_count - 1)
    end

    it "delete follower friendship when follower user deleted" do
      friendships_count = second_user.follower_friendships.count
      user.destroy!
      expect(second_user.follower_friendships.count).to eq(friendships_count - 1)
    end
  end

  describe "unfollows a user" do
    before do
      user.follow(second_user)
      user.follow(third_user)
      user.unfollow(second_user)
    end

    it "removes that user from user's followings" do
      expect(user.followings).not_to include(second_user)
    end

    it "does not removes other followings" do
      expect(user.followings).to include(third_user)
    end

    it "does not delete second user" do
      expect(described_class.find(second_user.id)).to be_truthy
    end

    it "removes follower from second user" do
      expect(second_user.followers).not_to include(user)
    end
  end
end
