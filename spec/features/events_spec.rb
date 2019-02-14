require "rails_helper"

RSpec.feature "Users interacts with Events" do
  scenario "A user can view Private and Public Events" do
    visit "/"
    jane = User.create!(
      firstname: 'Jane', 
      surname: 'Doe', 
      email: 'jane@example.com', 
      password: 'password2', 
      password_confirmation: 'password2'
      )
    
    private_event = Event.create!(
      name: 'Jane\'s Private Event',
    	description: 'Jane is creating a private event as a reminder to organise a surpirse dinner.',
    	price: 80.00,
    	location: nil,
    	date: 10.days.from_now,
    	private_event: true,
      user: jane
      )
    
    public_event = Event.create!(
      name: 'Jane\'s Public Event',
    	description: 'Come join Jane for a game of beach volleyball!',
    	price: 0.00,
    	location: "The beach",
    	date: 1.days.from_now,
    	private_event: false,
      user: jane
      )
    
    expect(page).to have_content("Public Events")
    expect(page).to have_content("Private Events")
    expect(assigns(:events).count).to eq 2
  end
end