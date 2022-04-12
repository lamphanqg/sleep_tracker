require "rails_helper"

RSpec.describe "/v1/users", type: :request do
  describe "follow" do
    let(:user) { User.create!(name: "Test user") }
    let(:another_user) { User.create!(name: "Another user") }

    it "returns ok" do
      post "/v1/users/#{user.id}/follow", params: {following_id: another_user.id}
      expect(response).to have_http_status(:ok)
    end

    it "increare user's followings" do
      followings_count = user.followings.count
      post "/v1/users/#{user.id}/follow", params: {following_id: another_user.id}
      expect(user.followings.count).to eq(followings_count + 1)
    end

    context "when user is inexistent" do
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

    context "when following user is inexistent" do
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
end
