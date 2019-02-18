class Event < ApplicationRecord
  belongs_to :user
  validates_presence_of :name, :date
  validates_length_of :description, minimum: 10

  validate :event_date_cannot_be_in_the_past

  def event_date_cannot_be_in_the_past
    if date.present? && date < DateTime.now
      errors.add(:date, "can't be in the past")
    end
  end 
end
