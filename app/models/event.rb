class Event < ApplicationRecord
  belongs_to :user
  validates :name, presence: true
  #   validates :date, not_in_past: true
#   validate :decription, length: { minimum: 10 }
  
end
