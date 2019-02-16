require 'rails_helper'

RSpec.describe Event, type: :model do
    context 'validation tests' do
        
    end
end

# Event
# Name (cannot be null)
# Description (at least 50 characters)
# Location (can be nil)
# Date (Cannot be in the past)
# Price (must be formatted correctly with 2 decimal places)
# User (must be made by current user)
# Private or Public (boolean)