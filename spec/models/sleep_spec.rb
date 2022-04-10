require "rails_helper"

RSpec.describe Sleep, type: :model do
  let!(:user) { User.create!(name: "Test") }
  let!(:sleep) { user.sleeps.create! }

  it "is invalid with ended_at before created_at" do
    sleep.ended_at = 1.hour.ago
    sleep.valid?
    expect(sleep.errors[:duration]).to include("must be greater than or equal to 0")
  end

  it "is unfinished after created" do
    expect(sleep.finished?).to be false
  end

  it "is finished when duration has value" do
    sleep.duration = 3600
    expect(sleep.finished?).to be true
  end

  describe "search finished sleeps" do
    it "does not include sleep without duration" do
      expect(described_class.finished).not_to include(sleep)
    end

    it "includes sleep with duration" do
      finished_sleep = user.sleeps.create!(duration: 3600)
      expect(described_class.finished).to include(finished_sleep)
    end
  end
end
