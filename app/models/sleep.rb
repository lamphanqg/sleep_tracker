class Sleep < ApplicationRecord
  belongs_to :user

  attr_accessor :ended_at

  before_validation :set_duration, if: :ended_at?

  scope :finished, -> { where.not(duration: nil) }

  validates :duration, numericality: {greater_than_or_equal_to: 0}, allow_nil: true

  def finished?
    duration.present?
  end

  private

  def set_duration
    self.duration = ended_at.to_i - created_at.to_i
  end

  def ended_at?
    ended_at.present?
  end
end
