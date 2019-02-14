require "rails_helper"

RSpec.feature "Admin Manages An Event" do
  scenario "An admin can login" do
    admin = User.create!(email: 'admin@example.com', password: 'password1', password_confirmation: 'password1')
    
    visit "/admin"
    
    fill_in "username", with: "admin"
    fill_in "password", with: "Password1"
    click_button "Login"

    expect(page).to have_content("Event")
    expect(page).to have_content("User")
  end
end