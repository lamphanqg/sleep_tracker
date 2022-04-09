require "rails_helper"

RSpec.describe User, type: :model do
  it "deletes associated sleeps when deleted" do
    sleeps_count = Sleep.count
    user = described_class.create!(name: "Test user")
    user.sleeps.create!
    user.destroy!
    expect(Sleep.count).to eq(sleeps_count)
  end
end
