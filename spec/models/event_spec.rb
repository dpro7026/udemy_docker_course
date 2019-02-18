require 'rails_helper'
require 'support/factory_bot'

RSpec.describe Event, type: :model do
    let(:user) { build(:user) }
    let(:event) { build(:event, user: user) }
    
    context 'validation tests' do
        it 'ensures name presence' do
            event.name = nil
            expect(event).to be_invalid
            event.name = 'Event Name'
            expect(event).to be_valid
        end
        
        it 'ensures description length minimum 10 characters' do
            event.description = "Too short"
            expect(event).to be_invalid
            event.description = "Event decription is over 10 characters."
            expect(event).to be_valid
        end
        
        # it 'ensures price format is always 2 decimal places' do
        #     # event.price = 1.1
        #     # expect(event.price).to eq(1.10)
        #     event.price = 1.111
        #     event.save
        #     expect(event.price).to eq(1.11)
        # end
        
        it 'ensures location can be nil' do
            event.location = nil
            expect(event.save).to eq(true)
        end
        
        it 'ensures date presence' do
            event.date = nil
            expect(event).to be_invalid
            event.date = DateTime.tomorrow
            expect(event).to be_valid
        end
        
        it 'ensures date cannot be in the past' do
            event.date = DateTime.yesterday
            expect(event.save).to eq(false)
            event.date = DateTime.tomorrow
            expect(event.save).to eq(true)
        end
        
        it 'save event' do
            expect { event.save }.to change { Event.count }.by(1)
            expect(Event.all).to include event
        end
        
        it 'destroys dependent events' do
            event.save
            expect { user.destroy }.to change { Event.count }.by(-1)
            expect(Event.all).to_not include event
        end
    end
end