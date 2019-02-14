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

```
docker-compose down
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

```

## Authors

**David Provest** - [LinkedIn](https://www.linkedin.com/in/davidjprovest/)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
