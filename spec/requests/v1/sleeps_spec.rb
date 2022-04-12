require "rails_helper"

RSpec.describe "/v1/sleeps", type: :request do
  let(:user) { User.create!(name: "Test user") }

  describe "clock in" do
    let(:sleeps_count) { user.sleeps.count }
    let(:clock_in_time) { 10.seconds.ago }

    before do
      user.sleeps.finished.destroy_all
    end

    context "when user is not sleeping" do
      before do
        sleeps_count
        post "/v1/users/#{user.id}/sleeps/clock_in", params: {clock_in_time: clock_in_time.iso8601}
      end

      it "returns ok" do
        expect(response).to have_http_status(:ok)
      end

      it "creates a new sleep" do
        expect(user.sleeps.count).to eq(sleeps_count + 1)
      end

      it "returns new sleep data" do
        json = JSON.parse(response.body)
        expect(json["duration"]).to be_nil
      end

      it "returns sleep data with correct created_at" do
        json = JSON.parse(response.body)
        expect(json["created_at"]).to eq(clock_in_time.iso8601)
      end
    end

    context "when user is sleeping" do
      let!(:sleep_created_at) { 6.hours.ago }
      let!(:sleep) { user.sleeps.create!(created_at: sleep_created_at) }

      before do
        sleeps_count
        post "/v1/users/#{user.id}/sleeps/clock_in", params: {clock_in_time: clock_in_time}
      end

      it "returns ok" do
        expect(response).to have_http_status(:ok)
      end

      it "does not create a new sleep" do
        expect(user.sleeps.count).to eq(sleeps_count)
      end

      it "returns updated sleep data" do
        json = JSON.parse(response.body)
        expect(json["id"]).to eq(sleep.id)
      end

      it "returns sleep with correct duration" do
        json = JSON.parse(response.body)
        expect(json["duration"]).to eq(clock_in_time.to_i - sleep_created_at.to_i)
      end
    end

    context "when use a different timezone" do
      before do
        time_in_zone = clock_in_time.in_time_zone("Asia/Ho_Chi_Minh")
        post "/v1/users/#{user.id}/sleeps/clock_in", params: {clock_in_time: time_in_zone.iso8601}
      end

      it "returns created_at in JST" do
        json = JSON.parse(response.body)
        expect(json["created_at"]).to eq(clock_in_time.in_time_zone("Asia/Tokyo").iso8601)
      end
    end

    context "when clock_in_time is before last sleep's created_at" do
      before do
        user.sleeps.create!(created_at: 6.hours.ago)
        post "/v1/users/#{user.id}/sleeps/clock_in", params: {clock_in_time: 7.hours.ago}
      end

      it "returns unprocessable_entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns duration error" do
        json = JSON.parse(response.body)
        expect(json["duration"]).to be_truthy
      end
    end

    context "when clock_in_time is missing" do
      before do
        post "/v1/users/#{user.id}/sleeps/clock_in"
      end

      it "returns bad request" do
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "when cannot parse clock_in_time to Time" do
      before do
        post "/v1/users/#{user.id}/sleeps/clock_in", params: {clock_in_time: "abc"}
      end

      it "returns bad request" do
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe "index" do
    let(:sleep_count) { 110 }

    before do
      sleep_count.times do
        user.sleeps.create!(created_at: rand(3600).seconds.ago, duration: rand(7200))
      end
    end

    context "when no parameter" do
      before do
        get "/v1/users/#{user.id}/sleeps"
      end

      it "returns ok" do
        expect(response).to have_http_status(:ok)
      end

      it "returns first 25 sleeps" do
        json = JSON.parse(response.body)
        expect(json["sleeps"].count).to eq(25)
      end

      it "returns sleeps ordered by created_at desc" do
        sleep_ids = user.sleeps.order(created_at: :desc).limit(25).pluck(:id)
        json = JSON.parse(response.body)
        expect(json["sleeps"].map { |sleep| sleep["id"] }).to match_array(sleep_ids)
      end

      it "returns total pages" do
        json = JSON.parse(response.body)
        expect(json["total_pages"]).to eq((sleep_count / 25.0).ceil)
      end

      it "returns total count" do
        json = JSON.parse(response.body)
        expect(json["total_count"]).to eq(user.sleeps.count)
      end
    end

    context "when specify 2nd page & 50 per page" do
      before do
        get "/v1/users/#{user.id}/sleeps", params: {page: 2, per_page: 50}
      end

      it "returns 51st to 100th sleeps" do
        sleep_ids = user.sleeps.order(created_at: :desc).offset(50).limit(50).pluck(:id)
        json = JSON.parse(response.body)
        expect(json["sleeps"].map { |sleep| sleep["id"] }).to match_array(sleep_ids)
      end
    end

    context "when per page greater than number of sleeps" do
      before do
        get "/v1/users/#{user.id}/sleeps", params: {per_page: 150}
      end

      it "returns all sleeps" do
        json = JSON.parse(response.body)
        expect(json["sleeps"].size).to eq(user.sleeps.count)
      end

      it "return total pages = 1" do
        json = JSON.parse(response.body)
        expect(json["total_pages"]).to eq(1)
      end
    end

    context "when user is sleeping" do
      before do
        user.sleeps.create!
        get "/v1/users/#{user.id}/sleeps"
      end

      it "returns ended_at = nil for the first sleep" do
        json = JSON.parse(response.body)
        expect(json["sleeps"].first["ended_at"]).to be_nil
      end
    end
  end
end
