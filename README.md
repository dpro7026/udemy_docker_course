# Modern Web Development - Udemy Course
## Course Overview
Modern web development leverages the power of the cloud to provide faster and more scalable applications. In this course we will learn best practices for web development using the Ruby on Rails framework but the methodologies we learn are translatable to any web language and any framework such as Javascript and Express.JS.

## Learning Outcomes
* Learn modern cloud native development (Cloud IDE and Docker)
* Use test driven development (TDD)
* Create a Rails 5 application

## Course Prerequisites
This course will use the a cloud integrated development environment (IDE), namely Cloud9 by Amazon Web Services for writing the code and running the development server. <strong>This course will ONLY use the free tier services but to create an account will require signing up and providing credit card details.</strong> You can alternatively choose to use a local Docker environment but as your operating system (OS) will vary no support will be provided if you choose a local environment.

## Installing & Running the Application
Installation uses Docker Compose:
```
docker-compose build
docker-compose up
docker-compose run railsapp rails db:create
```
<strong>Note: Running on AWS Cloud9 additionally requires running the following 2 scripts initially</strong>
<br/>
Expose the port 3000 to be publicly accessible:
```
security_group=$(ec2-metadata -s | cut -d " " -f 2)
aws ec2 authorize-security-group-ingress --group-name $security_group --protocol tcp --port 3000 --cidr 0.0.0.0/0
```
And get the URL:
```
ip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
echo "URL: http://$ip:3000"
```

## Stopping the App
To view the docker processes running:
```
docker ps
```
Stop all processes of the services defined in your `docker-compose` file with:
```
docker-compose down
```
If you are running out of memory then check the numer of replica docker images you have and destroy excess docker images:
```
docker images
docker system prune
```

# Lesson 1: Create a Hello World Rails 5 App with Docker Compose
## Environment Setup
We require `Docker` and `Docker-compose` installed on your environment.<br/>
[Link to Docker Compose Installation](https://docs.docker.com/compose/install/)
```
docker --version
sudo curl -L https://github.com/docker/compose/releases/download/1.24.0-rc1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

## Create the Rails 5 Application
Create a `Dockerfile` containing a small image of ruby, add additional packages and install Rails 5.2.1:
```
FROM ruby:alpine
RUN apk update && apk add --update build-base postgresql-dev nodejs tzdata
RUN gem install rails -v 5.2.1
```
Describe the 2 services (railsapp and postgres) by creating a `docker-compose.yml` containing:
```
version: '3'

services:
  postgres:
    container_name: postgres
    image: postgres
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-postgres}
      PGDATA: /data/postgres
    networks:
      - common-network
    volumes:
       - postgres:/data/postgres
    restart: unless-stopped

  railsapp:
    container_name: railsapp
    build: .
    working_dir: /railsapp
    image: dprovest/railsapp:latest
    command: bundle exec rails s -p 3000 -b '0.0.0.0'
    ports:
      - 3000:3000
    expose:
      - 3000
    depends_on:
      - postgres
    networks:
      - common-network
    volumes:
      - ./:/railsapp
    restart: on-failure

networks:
  common-network:
    driver: bridge

volumes:
  railsapp:
  postgres:

```
Build the image and then create the rails skeleton app (skipping Javascript files):
```
docker-compose build railsapp
docker-compose run railsapp rails new --database=postgresql -J .
```
<strong>Note:</strong> If you see warning that SCSS is being deprecated we can fix that by changing to use SASSC stylesheets instead.<br/>

Update the permissions so that we can read, write and execute the folders and files inside `/railsapp`:
```
sudo chmod -R 777 .
```
In the `Gemfile` remove:
```
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
```
And replace with:
```
# Use SASSC for stylesheets
gem 'sassc-rails'
```
<br/>

Update the `Dockerfile` to copy over the `Gemfile` and `Gemfile.lock` and install the gems:

```
WORKDIR /railsapp
ADD Gemfile Gemfile.lock /railsapp/
RUN bundle install
```
Now build the updated `Dockerfile` and start up the app:
```
docker-compose build
```
Optional: Login to your Docker Hub account and push your image:
```
docker login
```
Enter Docker Hub credentials, then:
```
docker-compose push
```
Run the application (both the railsapp and postgres services):
```
docker-compose up
```

<strong>Note: Running on AWS Cloud9 additionally requires running the following 2 scripts initially</strong>
<br/>
Expose the port 3000 to be publicly accessible:
```
security_group=$(ec2-metadata -s | cut -d " " -f 2)
aws ec2 authorize-security-group-ingress --group-name $security_group --protocol tcp --port 3000 --cidr 0.0.0.0/0
```
And get the URL:
```
ip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
echo "URL: http://$ip:3000"
```
Directing to the URL we can see our application running, albeit with a database error.<br/>

Configure the database by replacing the contents of `config/database.yml` with:
```
default: &default
  adapter: postgresql
  encoding: unicode
  host: postgres
  username: postgres
  password: postgres
  pool: 5

development:
  <<: *default
  database: railsapp_development

test:
  <<: *default
  database: railsapp_test
```
Restart the web app with:
```
docker-compose down
docker-compose up
```
Finally create the database:
```
docker-compose run web rails db:create
```
Visit *localhost:3000* and see the Hello World Rails app is running.</br>
Note: To stop the app use `docker-compose down` and restart it with `docker-compose up`</br>


# Lesson 2: Begin Test Driven Development 
## Install and configure RSpec, SimpleCov and Brakeman
We will use RSpec for writing our test scenarios, SimpleCov for code coverage and Brakeman for static code analysis.<br/>
Add to the `Gemfile` into the `group :test` block:
```
# Testing framework
gem 'rspec-rails'
# Code coverage
gem 'simplecov', require: false
```
Also add to the `Gemfile` into the `group :development` block:
```
# Static security vulnerability analysis
gem 'brakeman'
```
In Cloud9, use the settings icon next to the folders to turn 'Show Hidden Files' to on.<br/>
We don't want to upload the coverage reports to Git, so add the following line to `.gitignore`:
```
#Ignore coverage files
coverage/*
```
Update the bundle and install the gems:
```
docker-compose run railsapp bundle update
```
Re-build the container after updating `Gemfile`:
```
docker-compose build
```
Generate the RSpec configuration:
```
docker-compose run railsapp rails generate rspec:install
```
Ensure the correct version of RSpec is used:
```
docker-compose run railsapp bundle binstubs rspec-core
```
Update the permissions so that we can read, write and execute the folders and files inside `/railsapp`:
```
sudo chmod -R 777 .
```
At the top of `spec/spec_helper.rb`:
```
require 'simplecov'
SimpleCov.start 'rails' do
  # These filters are excluded from results
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
  add_filter '/test/'
  add_filter do |source_file|
    source_file.lines.count < 5
  end
end
```
Now when you run RSpec you will see the code coverage and generate a report in the coverage folder.</br>
```
docker-compose run railsapp rspec
```
To run Brakeman and store the report in our coverage folder:
```
docker-compose run railsapp brakeman -o coverage/brakeman_report
```

## Write specs for admins and events
We want to allow admins to manage users and events.<br/>
Create a new file in `spec/features` called `admin_spec.rb`:
```
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
```
We want to let users create both public events - can be viewed by anyone (does not require login) and private events - can only be viewed by the event creator when they are logged in.<br/>
Create a new file in `spec/features` called `events_spec.rb`:
```
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
```
Let\'s run our specs and see our first errors so we can begin writing our applcaition code:
```
docker-compose run railsapp rspec
```

# Lesson 3: Create a Homepage and add Bootstrap 4 Styling
Generate a Homepage with an index action:
```
docker-compose run railsapp rails g controller Homepage index
```
Update the root URL in `config/routes.rb`:
```
Rails.application.routes.draw do
  get 'homepage/index'
  root 'homepage#index'
end
```
Run the specs and see that scenario 2 now has a new error:
```
docker-compose run railsapp rspec
```
Update the permissions so that we can read, write and execute the newly generated files:
```
sudo chmod -R 777 .
```
Visit [Bootstrap 4 Buttons](https://getbootstrap.com/docs/4.0/components/buttons/).<br/>
We will add a primary (blue) Bootstrap button to `app/views/homepage/index.html.erb`:
```
<h1>Homepage</h1>
<button type="button" class="btn btn-primary">Button</button>
```
Refresh the app and see the button is not styled yet.<br/>
Add to the `Gemfile` (not in a group) the following:
```
# Add Bootstrap 4 for CSS styling
gem 'bootstrap', '~> 4.2.1'
# Add JQuery as Rails 5 doesn't include this by default
gem 'jquery-rails'
```
Update the bundle and install the gems:
```
docker-compose run railsapp bundle update
```
Build the Docker image (required anytime the Gemfile is modified):
```
docker-compose build
```
Run the following command to rename the `application.css` to `application.scss`, this changes the file extension.
```
mv app/assets/stylesheets/application.css app/assets/stylesheets/application.scss
```
Open the `app/assets/stylesheets/application.scss` and replace the contents with:
```
@import "bootstrap";
```
Open app/assets/javascripts/application.js above //= require_tree .:
```
//= require jquery3
//= require popper
//= require bootstrap-sprockets
```
Refresh the page to see the style button.

# Lesson 4: Create Users and Events
We will use Devise to setup our Users (ensures authenitcation).<br/> 
Add Devise gem to the `Gemfile`:
```
# For user authentication
gem 'devise', '~> 4.3'
```
Update the bundle and install the gems:
```
docker-compose run railsapp bundle update
```
Build the Docker image (required anytime the `Gemfile` is modified):
```
docker-compose build
```
Run devise generator (read the instruction output):
```
docker-compose run railsapp rails generate devise:install
```
Update the permissions of the new files generated:
```
sudo chmod -R 777 .
```
Add the following to `config/environments/development.rb`:
```
# define default url options for mailer
config.action_mailer.default_url_options = { host: ENV['IP'], port: ENV['PORT'] }
```
Add users using Devise generator:
```
docker-compose run railsapp rails generate devise User
```
Update the permissions of the new files generated:
```
sudo chmod -R 777 .
```
Update the migration file `<timestamp>_devise_create_users.rb` with additional columns:
```
create_table :users do |t|
  ## Adding our own additional columns to the User table
  t.string :firstname,           null: false
  t.string :surname,             null: false

  ## Database authenticatable
  t.string :email,              null: false, default: ""
  t.string :encrypted_password, null: false, default: ""
  ...
```
Generate an Event scaffold:
```
docker-compose run railsapp rails g scaffold Event name:string description:text price:decimal location:string date:datetime private_event:boolean user:references 
```
Update the permissions of the new files generated:
```
sudo chmod -R 777 .
```
Update the root in `config/routes.rb`:
```
root 'events#index'
```
Update the `db/seeds.rb` with a default user:
```
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
```
Run database migrations:
```
docker-compose run railsapp rails db:migrate
```
Reset the databases:
```
docker-compose run railsapp rails db:reset
```
View the webpage and run the spec to see the code coverage and where the spec is failing:
```
docker-compose run railsapp rspec
```
We now have Users and Events and will need to write more specs to increase our code coverage. However, first we will add and admin user.


# Lesson 5: Create an Admin Dashboard for Managing Users and Events
Add Activeadmin gem to the Gemfile:
```
# For managing admins
gem 'activeadmin', '~> 1.1'
```
Update the bundle and install the gems:
```
docker-compose run railsapp bundle update
```
Build the Docker image (required anytime the `Gemfile` is modified):
```
docker-compose build
```
Run Activeadmin generator:
```
docker-compose run railsapp rails g active_admin:install
```
Update the permissions of the new files generated:
```
sudo chmod -R 777 .
```
We ALWAYS want to change the default admin credentials. Open `db/seeds.rb` and update the admin credentials.
```
AdminUser.create!(email: 'admin@example.com', password: 'admin1', password_confirmation: 'admin1')
```
Run database migrations (migrates `db/migrate/*`):
```
docker-compose run railsapp rails db:migrate
```
Reset the databases:
```
docker-compose run railsapp rails db:reset
```
Restart the services using docker-compose:
```
docker-compose down
docker-compose up -d
```
Browse to <URL>/admin to login and view the admin dashboard. Notice the dashboard does not show Users or Events.<br/>
Stop the application and add Users and Events to the Admin dashboard:
```
docker-compose run railsapp rails g active_admin:resource User
docker-compose run railsapp rails g active_admin:resource Event
```
Update the permissions of the new files generated:
```
sudo chmod -R 777 .
```
Start the application and view the new Users and Events tabs and see the associated data for these models.
Run the specs and see that that scenario 1 now passes: 
```
docker-compose run railsapp rspec
```

# Lesson 6: Model Validations and Associations
Create a new folder `spec/models` containing a file `event_spec.rb`:
```
require 'rails_helper'
require 'support/factory_bot'

RSpec.describe Event, type: :model do
    let(:user) { build(:user) }
    let(:event) { build(:event, user: user) }
    
    context 'validation tests' do
        it 'ensures name presence' do
            event.name = nil
            expect(event.save).to eq(false)
            event.name = 'Event Name'
            expect(event.save).to eq(true)
        end
        
        it 'ensures decription length > 10 characters' do
            event.location = "Too short"
            expect(event.save).to eq(false)
            event.name = "Event decription is over 10 characters"
            expect(event.save).to eq(true)
        end
        
        it 'ensures location can be nil' do
            event.location = nil
            expect(event.save).to eq(true)
        end
        
        it 'ensures date cannot be in the past' do
            event.date = DateTime.yesterday
            expect(event.save).to eq(false)
            event.date = DateTime.tomorrow
            expect(event.save).to eq(true)
        end
        
        it 'ensures price format is always 2 decimal places' do
            event.price = 1.1
            expect(event.price).to eq(1.10)
            event.price = 1.111
            expect(event.price).to eq(1.11)
        end
    end
end
```


Update migration to ensure that price has exactly 2 decimal places: 
```
rails g migration change_event_price_to_exactly_two_decimal_places
```
Update permissions:
```
sudo chmod -R 777 .
```
Update the new file `db/migrate/<time_stamp>_change_event_price_to_exactly_two_decimal_places.rb`. 
Using the up and down format, rather than change allows for rollbacks: 
```
class ChangeEventPriceToExactlyTwoDecimalPlaces < ActiveRecord::Migration[5.2]
  # change_column :table_name, :column_name, :new_type
  def up
    change_column :events, :price, :decimal
  end

  def down
    change_column :events, :price, :decimal, scale: 2
  end
end
```

# Lesson 7: Feature/Integration Testing 
Add gems to `group :development, :test do` including Fuubar, Factory Bot and Faker: 
```
# Spec progress bar
gem 'fuubar'
# Use factories to create sample instances of objects
gem 'factory_bot_rails'
# Use faker to generate sample data
gem 'faker'
```
Update the bundle and install the gems:
```
docker-compose run railsapp bundle update
```
Build the Docker image (required anytime the `Gemfile` is modified):
```
docker-compose build
```
Update the `.rspec` config to use Fuubar:
```
--format Fuubar
--color
```
Run the specs and see the new progress bar, which is ver helpful when tests are long running: 
```
docker-compose run railsapp rspec
``` 
Create a new folder `spec/support` containing a file `factory_bot.rb`. Add the following initialiser configuration to this file:
```
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
```
Create a new file `spec/support/warden.rb`. Add the following initialiser configuration so we can use login_as and similar Warden helper methods in our specs:
```
RSpec.configure do |config|
  config.include Warden::Test::Helpers
end
```
We will now use factories that we can instantiate objects from.<br/>
Create a new folder `spec/factories` containing a file `users.rb` containing:
```
FactoryBot.define do
  factory :user do
    firstname { 'Jane' }
    surname { 'Doe' }
    email { 'jane@example.com' }
    password { 'password2' }
  end
  
  factory :another_user, class: User do
    firstname { 'Tom' }
    surname { 'Smith' }
    email { 'tom@example.com' }
    password { 'password3' }
  end

  factory :random_user, class: User do
    firstname { Faker::Pokemon.name }
    surname { Faker::Pokemon.name }
    email { Faker::Internet.safe_email }
    password { 'password' }
  end
end
```
Update `spec/features/events_spec.rb` to require Factory Bot and build the user using the factory:
```
require 'rails_helper'
require 'support/factory_bot'

RSpec.feature "Users interacts with Events" do
  given!(:jane) { build(:user) }
  
  scenario "A user can view Private and Public Events" do
    visit "/"
    
    private_event = Event.create!(
      name: 'Jane\'s Private Event',
    	description: 'Jane is creating a private event as a reminder to organise a surpirse dinner.',
    	price: 80.00,
    	location: nil,
    	date: 10.days.from_now,
    	private_event: true,
      user: jane
      )
    
  end
end
```
Create a new factory for events at `spec/factories/events.rb` containing:
```
FactoryBot.define do
  factory :event do
    name { 'Jane\'s Public Event' }
    description { 'Jane is hosting a super fun event' }
    price { 0.00 }
    location { 'Jane\'s house' }
    date { 10.days.from_now }
    private_event { false }
    user { nil }
  end
  
  factory :another_event, class: Event do
    name { 'Tom\'s Public Event' }
    description { 'Tom is hosting a a party!' }
    price { 10.00 }
    location { 'Tom\'s house' }
    date { 10.days.from_now }
    private_event { false }
    user { nil }
  end
end
```
Update the `spec/features/events_spec.rb` to test for all the integration logic of public and priavte events:
```
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
```



```
RSpec.configure do |config|
  config.include Warden::Test::Helpers
  config.after :each do
    Warden.test_reset!
  end
end
```



## Authors

**David Provest** - [LinkedIn](https://www.linkedin.com/in/davidjprovest/)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
