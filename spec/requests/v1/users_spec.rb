require "rails_helper"
require "requests/shared_examples"

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

      it_behaves_like "a not found error"
    end

    context "when following user not exists" do
      before do
        post "/v1/users/#{user.id}/follow", params: {following_id: 5}
      end

      it_behaves_like "a not found error"
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

    it_behaves_like "a successful request"

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

  describe "pagination for friend list" do
    let(:json) { JSON.parse(response.body) }

    before do
      30.times do |i|
        new_user = User.create!(name: "User #{i}")
        user.follow(new_user)
      end
    end

    it "returns 25 friends when no parameter specified" do
      get "/v1/users/#{user.id}/friends"
      expect(json["friends"].count).to eq(25)
    end

    context "when specify 2nd page and 10 per page" do
      before do
        get "/v1/users/#{user.id}/friends", params: {page: 2, per_page: 10}
      end

      it "returns 11th-20th friends when specify 2nd page and 10 per page" do
        friend_ids = User.friends_of(user).order(:id).offset(10).limit(10).pluck(:id)
        expect(json["friends"].map { |friend| friend["id"] }).to eq(friend_ids)
      end

      it "returns total count" do
        expect(json["total_count"]).to eq(30)
      end

      it "return total page" do
        expect(json["total_pages"]).to eq(3)
      end
    end
  end
end
