require "rails_helper"

RSpec.describe V1::SleepsController, type: :routing do
  describe "routing" do
    it "routes to #clock_in" do
      expect(post: "/v1/users/12/sleeps/clock_in").to route_to(controller: "v1/sleeps", action: "clock_in", user_id: "12")
    end
  end
end
