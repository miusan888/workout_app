class Exercise < ApplicationRecord
  belongs_to :user

  validates :duration, numericality: { only_integer: true, greater_than: 0 }
  validates :exercised_on, presence: true
end
