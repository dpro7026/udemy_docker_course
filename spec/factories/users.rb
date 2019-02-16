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
