require 'rails_helper'
require 'support/factory_bot'
require 'support/warden' 

# Always test the passing and failing scenarios
RSpec.feature "Events are dependent on a user" do
  given(:jane) { build(:user) }
  
  scenario "Event has a user" do
    janes_event = build(:event, user: jane)
    expect(janes_event.save).to eq(true)
    expect(janes_event.name).to eq('Jane\'s Public Event')
  end
  
  scenario 'Event has no user' do
    janes_event = build(:event, user: nil)
    expect(janes_event.save).to eq(false)
  end
end

RSpec.feature "Private events are only visible to their creator" do
  given!(:jane) { create(:user) }
  given!(:tom) { create(:another_user) }
  given!(:janes_private_event) { create(:event, user: jane, name: "Jane's Private Event", private_event: true) }
  given!(:janes_public_event) { create(:event, user: jane, private_event: false) }
  given!(:toms_private_event) { create(:another_event, name: "Tom's Private Event", user: tom, private_event: true) }
  given!(:toms_public_event) { create(:another_event, user: tom, private_event: false) }
  
  scenario "when user logged in they can see all their events" do
    login_as jane
    visit "/"
    expect(page).to have_content("Public Events")
    expect(page).to have_content("Jane's Public Event")
    expect(page).to have_content("Private Events")
    expect(page).to have_content("Jane's Private Event")
  end
  
  scenario "when user logged in they can't see other user's private events" do
    login_as tom
    visit "/"
    expect(page).to have_content("Public Events")
    expect(page).to have_content("Jane's Public Event")
    expect(page).to have_content("Tom's Public Events")
    expect(page).to have_content("Private Events")
    expect(page).to have_content("Tom's Private Events")
    expect(page).to_not have_content("Jane's Private Event")
  end
  
  scenario "when user not logged in they can't see any private events" do
    visit "/"
    expect(page).to have_content("Public Events")
    expect(page).to have_content("Jane's Public Event")
    expect(page).to have_content("Tom's Public Events")
    expect(page).to_not have_content("Private Events")
    expect(page).to_not have_content("Jane's Private Event")
    expect(page).to_not have_content("Tom's Private Event")
  end
end