RSpec.configure do |config|
  config.include Warden::Test::Helpers, type: :feature
  # config.after :each do
  #   Warden.test_reset!
  # end
end