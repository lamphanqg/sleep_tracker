require "rails_helper"

RSpec.describe V1::UsersController, type: :routing do
  describe "routing" do
    it "routes to #follow" do
      expect(post: "/v1/users/12/follow").to route_to(
        controller: "v1/users", action: "follow",
        id: "12", format: "json"
      )
    end

    it "routes to #unfollow" do
      expect(delete: "/v1/users/12/unfollow").to route_to(
        controller: "v1/users", action: "unfollow",
        id: "12", format: "json"
      )
    end

    it "routes to #friends" do
      expect(get: "/v1/users/12/friends").to route_to(
        controller: "v1/users", action: "friends",
        id: "12", format: "json"
      )
    end
  end
end
