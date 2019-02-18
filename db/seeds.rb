if Rails.env.development?
    AdminUser.create!(
        email: 'admin@example.com', 
        password: 'admin1', 
        password_confirmation: 'admin1'
        )
    
    john = User.create!(
        firstname: 'John', 
        surname: 'Smith', 
        email: 'john@example.com', 
        password: 'password1', 
        password_confirmation: 'password1'
        )

    johns_public_event = Event.create!(
        name: 'John\'s Public Event',
    	description: 'Come to John\'s house for the best BBQ of your life!',
    	price: 0.00,
    	location: 'John\'s House',
    	date: DateTime.new(2019,9,5,12,0),
    	private_event: false,
    	user: john
        )
        
    johns_private_event = Event.create!(
        name: 'John\'s Private Event',
    	description: 'John\'s secret event',
    	price: 0.00,
    	location: 'John\'s Secret Lair',
    	date: DateTime.new(2020,9,5,12,0),
    	private_event: true,
    	user: john
        )
end