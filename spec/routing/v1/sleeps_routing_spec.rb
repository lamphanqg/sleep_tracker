require "rails_helper"

RSpec.describe V1::SleepsController, type: :routing do
  describe "routing" do
    it "routes to #clock_in" do
      expect(post: "/v1/users/12/sleeps/clock_in").to route_to(
        controller: "v1/sleeps", action: "clock_in",
        user_id: "12", format: "json"
      )
    end

    it "routes to #index" do
      expect(get: "/v1/users/12/sleeps").to route_to(
        controller: "v1/sleeps", action: "index",
        user_id: "12", format: "json"
      )
    end
  end
end
