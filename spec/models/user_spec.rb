require "rails_helper"

RSpec.describe User, type: :model do
  let(:user) { described_class.create!(name: "Test user") }
  let(:second_user) { described_class.create!(name: "Second user") }

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
end
