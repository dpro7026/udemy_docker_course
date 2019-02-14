require "rails_helper"

RSpec.feature "User Views Events" do
  scenario "Can view public events" do
    visit "/"

    expect(page).to have_content("Events")
    expect(assigns(:events)).to_not be_empty
    expect(assigns(:events).count).to eq 3
  end
  
  scenario "Can view public and private events" do
    john = User.create!(firstname: 'John', surname: 'Smith', email: 'john@example.com', password: 'password1', password_confirmation: 'password1')
    
    visit "/"

    expect(page).to have_content("Events")
    expect(assigns(:events)).to_not be_empty
    expect(assigns(:events).count).to eq 3
  end
end