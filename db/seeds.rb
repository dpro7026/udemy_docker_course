if Rails.env.development?
    john = User.create!(
        firstname: 'John', 
        surname: 'Smith', 
        email: 'john@example.com', 
        password: 'password1', 
        password_confirmation: 'password1'
        )

    johns_event = Event.create!(
        name: 'John\'s Event',
    	description: 'Come to John\'s house for the best BBQ of your life!',
    	price: 0.00,
    	location: 'John\'s House',
    	date: DateTime.new(2019,9,5,12,0),
    	private_event: false,
    	user: john
        )
end