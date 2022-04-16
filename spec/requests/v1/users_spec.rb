require "rails_helper"

RSpec.describe "/v1/users", type: :request do
  let(:user) { User.create!(name: "Test user") }
  let(:another_user) { User.create!(name: "Another user") }
  let(:third_user) { User.create!(name: "Third user") }

  describe "follow" do
    it "returns ok" do
      post "/v1/users/#{user.id}/follow", params: {following_id: another_user.id}
      expect(response).to have_http_status(:ok)
    end

    it "increare user's followings" do
      followings_count = user.followings.count
      post "/v1/users/#{user.id}/follow", params: {following_id: another_user.id}
      expect(user.followings.count).to eq(followings_count + 1)
    end

    context "when user not exists" do
      before do
        post "/v1/users/100/follow", params: {following_id: another_user.id}
      end

      it "returns not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns message user not found" do
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("user not found")
      end
    end

    context "when following user not exists" do
      before do
        post "/v1/users/#{user.id}/follow", params: {following_id: 5}
      end

      it "returns not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns message following user not found" do
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("following user not found")
      end
    end
  end

  describe "unfollow" do
    before do
      user.follow(another_user)
    end

    it "returns ok" do
      delete "/v1/users/#{user.id}/unfollow", params: {following_id: another_user.id}
      expect(response).to have_http_status(:ok)
    end

    it "decrease user's followings" do
      followings_count = user.followings.count
      delete "/v1/users/#{user.id}/unfollow", params: {following_id: another_user.id}
      expect(user.followings.count).to eq(followings_count - 1)
    end
  end

  describe "friends" do
    let(:json) { JSON.parse(response.body) }

    before do
      user.follow(another_user)
      third_user.follow(user)
      user.sleeps.destroy_all
      7.times do |i|
        another_user.sleeps.create!(created_at: (i + 1).days.ago, duration: rand(30_000))
        third_user.sleeps.create!(created_at: (i + 1).days.ago, duration: rand(30_000))
      end
      get "/v1/users/#{user.id}/friends"
    end

    it "returns ok" do
      expect(response).to have_http_status(:ok)
    end

    it "returns both followings and followers" do
      friend_ids = json["friends"].map { |friend| friend["id"] }
      expect(friend_ids).to include(another_user.id, third_user.id)
    end

    describe "sleeps of friends" do
      let(:sleeps) { json["friends"].map { |friend| friend["sleeps"] }.flatten }
      let(:first_friend_sleeps) { json["friends"].first["sleeps"] }

      it "include sleeps from 7 days ago" do
        expect(sleeps.count { |sleep| sleep["created_at"] >= 1.week.ago }).to eq(12)
      end

      it "does not include sleeps before 7 days ago" do
        expect(sleeps.select { |sleep| sleep["created_at"] < 1.week.ago }).to be_empty
      end

      it "are sorted in desc order of duration" do
        sorted_sleeps = first_friend_sleeps.sort_by { |sleep| Time.zone.parse(sleep["created_at"]) }.reverse
        expect(first_friend_sleeps).to eq(sorted_sleeps)
      end
    end
  end
end
