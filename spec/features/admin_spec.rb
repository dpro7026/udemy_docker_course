require "rails_helper"

RSpec.feature "Admin manages Events and Users" do
  scenario "An admin can login" do
    new_admin = User.create!(email: 'admin2@example.com', password: 'password2', password_confirmation: 'password2')

    visit "/admin"
    
    fill_in "email", with: new_admin.email
    fill_in "password", with: new_admin.password
    click_button "Login"

    expect(page).to have_content("Event")
    expect(page).to have_content("User")
  end
end